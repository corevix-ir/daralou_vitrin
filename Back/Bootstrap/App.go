package Bootstrap

import (
	"Back/Auth"
	"Back/Config"
	Controllers "Back/Controller"
	"Back/Realtime"
	"Back/Repositories"
	Routes "Back/Routs"
	"Back/Scraper"
	Services "Back/Service"
	"Back/Validation"
	_ "Back/docs" // مستندات تولیدشده توسط `swag init` - قبل از build باید تولید شده باشه
	Mymiddleware "Back/Middleware"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	echoSwagger "github.com/swaggo/echo-swagger"
	"log"
	"os"
	"time"
)

// مقادیر پیش‌فرض عمر توکن‌ها وقتی ACCESS_TOKEN_TTL / REFRESH_TOKEN_TTL در .env
// تنظیم نشده یا نامعتبر باشند.
const (
	defaultAccessTokenTTL  = 6 * time.Hour
	defaultRefreshTokenTTL = 90 * 24 * time.Hour
)

// parseTTL مقدار یک متغیر محیطی را به‌صورت Duration می‌خواند (مثل "6h" یا "2160h").
// اگر خالی یا نامعتبر باشد، مقدار پیش‌فرض را برمی‌گرداند.
func parseTTL(envValue string, fallback time.Duration, envName string) time.Duration {
	if envValue == "" {
		return fallback
	}
	parsed, err := time.ParseDuration(envValue)
	if err != nil {
		log.Printf("مقدار %s نامعتبر است (%q)، از مقدار پیش‌فرض %s استفاده می‌شود", envName, envValue, fallback)
		return fallback
	}
	return parsed
}

func InitializeApp() *echo.Echo {
	// راه‌اندازی Echo
	e := echo.New()

	// تنظیم Validator - این خط مهمه!
	e.Validator = Validation.NewValidator()

	//e.Use(middleware.BodyLimit("5M")) // محدودیت 5MB برای آپلود فایل

	// راه‌اندازی دیتابیس و اسکرپر کالی
	db := Config.GetDB()
	scraper := Config.GetCollyScraper()

	// سرو فایل‌های استاتیک (تصاویر اخبار اسکرپ‌شده و آپلودی) روی /static
	// قبلاً این خط کامنت بود و اصلاً هیچ‌چیزی سرو نمی‌شد؛ main_img در پاسخ API
	// هم مسیر مطلق دیسک سرور بود که از هیچ مرورگری قابل‌دسترس نیست.
	if scraper.BaseImagePath == "" {
		log.Println("هشدار: BASE_IMAGE_PATH تنظیم نشده - تصاویر سرو نخواهند شد")
	} else {
		e.Static("/static", scraper.BaseImagePath)
	}

	// راه‌اندازی ریپوزیتوری ها
	userRepo := Repositories.NewUserRepository(db)
	contentRepo := Repositories.NewContentRepository(db)
	deviceRepo := Repositories.NewDeviceRepository(db)

	// ---------------------------------------------------------------
	// FIX #5: اعتبارسنجی متغیرهای محیطی مربوط به JWT
	// اگر این مقادیر خالی باشن، توکن‌ها با secret خالی امضا میشن که خیلی خطرناکه
	// ---------------------------------------------------------------
	accessSecret := os.Getenv("ACCESS_TOKEN")
	refreshSecret := os.Getenv("REFRESH_TOKEN")
	issuer := os.Getenv("ISSUER")

	if accessSecret == "" || refreshSecret == "" || issuer == "" {
		log.Fatal("متغیرهای محیطی ACCESS_TOKEN, REFRESH_TOKEN و ISSUER باید تنظیم شده باشند")
	}

	accessTokenTTL := parseTTL(os.Getenv("ACCESS_TOKEN_TTL"), defaultAccessTokenTTL, "ACCESS_TOKEN_TTL")
	refreshTokenTTL := parseTTL(os.Getenv("REFRESH_TOKEN_TTL"), defaultRefreshTokenTTL, "REFRESH_TOKEN_TTL")

	// راه‌اندازی سرویس ها
	jwtService := Auth.NewJWTService(accessSecret, refreshSecret, issuer, accessTokenTTL, refreshTokenTTL)

	authService := Services.NewAuthService(userRepo, jwtService)
	deviceService := Services.NewDeviceService(deviceRepo, authService)
	contentService := Services.NewContentService(contentRepo, scraper.BaseImagePath)

	scraperService := Scraper.NewScrapCollyService(contentRepo, scraper.Collector, scraper.BaseImagePath)
	Scraper.StartScraperScheduler(scraperService)
	go func() {
		if err := scraperService.ScrapDaralouNews(); err != nil {
			log.Println("[SCRAPER] Initial run error:", err)
		}
	}()

	// راه‌اندازی هاب بلادرنگ (Socket.IO) برای ارسال دستور به دستگاه‌ها
	realtimeHub := Realtime.NewHub(jwtService, deviceService)

	// راه‌اندازی کنترلرها
	authController := Controllers.NewAuthController(authService)
	contentController := Controllers.NewContentController(contentService, deviceService)
	deviceController := Controllers.NewDeviceController(deviceService, realtimeHub)

	// راه‌اندازی Middleware ها
	jwtMiddleware := Mymiddleware.NewAuthMiddleware(jwtService)
	roleMiddleware := Mymiddleware.NewRoleMiddleware(authService) // middleware نقش‌ها

	// Middleware های عمومی
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	// ---------------------------------------------------------------
	// FIX #1: حذف middleware.CORS() تکراری - قبلاً اول یه CORS بازِ
	// همه-origin اضافه می‌شد و بلافاصله override می‌شد، که فقط گیج‌کننده
	// بود. فقط پیکربندی محدودشده باقی می‌مونه.
	// ---------------------------------------------------------------
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: []string{"http://localhost:8081"}, // فقط فرانت لوکال
		AllowMethods: []string{"GET", "POST", "PUT", "DELETE"},
		AllowHeaders: []string{"Authorization", "Content-Type", "X-Kiosk-ID"},
	}))

	// مستندات Swagger روی /swagger/index.html
	e.GET("/swagger/*", echoSwagger.WrapHandler)

	// اتصال بلادرنگ (Socket.IO) - دستگاه‌ها بعد از لاگین به اینجا وصل می‌شوند
	// تا بتوانیم بدون پولینگ دستور فوری (باز کردن پنل ادمین و غیره) بفرستیم.
	e.Any("/socket.io", echo.WrapHandler(realtimeHub.Handler()))
	e.Any("/socket.io/*", echo.WrapHandler(realtimeHub.Handler()))

	// ثبت مسیرها
	Routes.RegisterAuthRoutes(e, authController, jwtMiddleware, roleMiddleware)
	Routes.RegisterContentRoutes(e, contentController, jwtMiddleware, roleMiddleware)
	Routes.RegisterDeviceRoutes(e, deviceController, jwtMiddleware, roleMiddleware)

	return e
}
