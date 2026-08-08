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
	Mymiddleware "Back/middleware"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
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

	// راه‌اندازی سرویس ها
	jwtService := Auth.NewJWTService(
		os.Getenv("ACCESS_TOKEN"),
		os.Getenv("REFRESH_TOKEN"),
		os.Getenv("ISSUER"),
	)

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
	e.Use(middleware.CORS())
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: []string{"http://localhost:8081"}, // فقط فرانت لوکال
		AllowMethods: []string{"GET", "POST", "PUT", "DELETE"},
		AllowHeaders: []string{"Authorization", "Content-Type"},
	}))

	// ثبت مسیرها
	Routes.RegisterAuthRoutes(e, authController, jwtMiddleware, roleMiddleware)
	Routes.RegisterContentRoutes(e, contentController, jwtMiddleware, roleMiddleware)
	Routes.RegisterDeviceRoutes(e, deviceController, jwtMiddleware, roleMiddleware)

	return e
}
