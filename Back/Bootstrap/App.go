package Bootstrap

import (
	"Back/Auth"
	"Back/Config"
	Controllers "Back/Controller"
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
)

func InitializeApp() *echo.Echo {
	// راه‌اندازی Echo
	e := echo.New()

	// تنظیم Validator - این خط مهمه!
	e.Validator = Validation.NewValidator()

	//e.Use(middleware.BodyLimit("5M")) // محدودیت 5MB برای آپلود فایل
	// سرو فایل‌های استاتیک
	//e.Static("/uploads", "uploads") // فایل‌های آپلود شده

	// راه‌اندازی دیتابیس و اسکرپر کالی
	db := Config.GetDB()
	scraper := Config.GetCollyScraper()

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

	// راه‌اندازی سرویس ها
	jwtService := Auth.NewJWTService(accessSecret, refreshSecret, issuer)

	authService := Services.NewAuthService(userRepo, jwtService)
	deviceService := Services.NewDeviceService(deviceRepo, authService)
	contentService := Services.NewContentService(contentRepo)

	scraperService := Scraper.NewScrapCollyService(contentRepo, scraper.Collector, scraper.BaseImagePath)
	Scraper.StartScraperScheduler(scraperService)
	go func() {
		if err := scraperService.ScrapDaralouNews(); err != nil {
			log.Println("[SCRAPER] Initial run error:", err)
		}
	}()

	// راه‌اندازی کنترلرها
	authController := Controllers.NewAuthController(authService)
	contentController := Controllers.NewContentController(contentService, deviceService)
	deviceController := Controllers.NewDeviceController(deviceService)

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
		AllowHeaders: []string{"Authorization", "Content-Type"},
	}))

	// مستندات Swagger روی /swagger/index.html
	e.GET("/swagger/*", echoSwagger.WrapHandler)

	// ثبت مسیرها
	Routes.RegisterAuthRoutes(e, authController, jwtMiddleware, roleMiddleware)
	Routes.RegisterContentRoutes(e, contentController, jwtMiddleware, roleMiddleware)
	Routes.RegisterDeviceRoutes(e, deviceController, jwtMiddleware, roleMiddleware)

	return e
}
