package Config

import (
	"Back/Models"
	"fmt"
	"log"
	"os"
	"sync"
	"time"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres" // تغییر از mysql به postgres
	"gorm.io/gorm"
)

var (
	db   *gorm.DB
	once sync.Once
)

func GetDB() *gorm.DB {
	once.Do(func() {
		initializeDB()
	})
	return db
}

func initializeDB() {
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("Error loading .env file %v", err)
	}

	// خواندن مشخصات اتصال PostgresSQL از متغیرهای محیطی
	dbUser := os.Getenv("DB_USER")
	dbPassword := os.Getenv("DB_PASSWORD")
	dbHost := os.Getenv("DB_HOST")
	dbPort := os.Getenv("DB_PORT")
	dbName := os.Getenv("DB_NAME")
	sslMode := os.Getenv("DB_SSLMODE") // برای محیط توسعه معمولاً "disable" است

	if dbUser == "" || dbPassword == "" || dbHost == "" || dbPort == "" || dbName == "" {
		log.Fatal("Missing database configuration in environment variables")
	}

	// اگر دیتابیس هدف روی سرور Postgres وجود نداشته باشه، خودش می‌سازدش -
	// دیگه نیازی به ساخت دستی دیتابیس قبل از اجرای برنامه نیست.
	if err := ensureDatabaseExists(dbHost, dbPort, dbUser, dbPassword, dbName, sslMode); err != nil {
		log.Fatalf("Failed to ensure database exists: %v", err)
	}

	// ساخت رشته اتصال PostgresSQL
	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=%s TimeZone=Asia/Tehran",
		dbHost, dbUser, dbPassword, dbName, dbPort, sslMode)

	// باز کردن اتصال دیتابیس
	connection, err2 := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err2 != nil {
		log.Fatalf("Failed to connect to the database: %v", err2)
	}

	// تنظیم پارامترهای اتصال
	sqlDB, err1 := connection.DB()
	if err1 != nil {
		log.Fatalf("Failed to get SQL DB instance: %v", err1)
	}

	sqlDB.SetMaxIdleConns(20)                  // حداکثر تعداد اتصالات بیکار
	sqlDB.SetMaxOpenConns(100)                 // حداکثر تعداد اتصالات باز
	sqlDB.SetConnMaxLifetime(time.Minute * 30) // عمر هر اتصال 30 دقیقه است

	// همگام‌سازی خودکار اسکیما (ساخت جدول‌ها/ستون‌های جدید) - نیازی به اجرای
	// دستی migration نیست.
	if err := runMigrations(connection); err != nil {
		log.Fatalf("Failed to run migrations: %v", err)
	}

	db = connection
}

// ensureDatabaseExists با اتصال به دیتابیس نگهداریِ postgres چک می‌کنه دیتابیس
// هدف (dbName) از قبل وجود داره یا نه؛ اگر نبود، خودش با CREATE DATABASE
// می‌سازدش. کاربر Postgres تنظیم‌شده در .env باید دسترسی CREATEDB داشته باشه.
func ensureDatabaseExists(host, port, user, password, dbName, sslMode string) error {
	maintenanceDSN := fmt.Sprintf("host=%s user=%s password=%s dbname=postgres port=%s sslmode=%s",
		host, user, password, port, sslMode)

	maintenanceConn, err := gorm.Open(postgres.Open(maintenanceDSN), &gorm.Config{})
	if err != nil {
		return fmt.Errorf("اتصال به دیتابیس نگهداری (postgres) ناموفق بود: %w", err)
	}
	sqlDB, err := maintenanceConn.DB()
	if err != nil {
		return err
	}
	defer sqlDB.Close()

	var exists bool
	if err := maintenanceConn.Raw(
		"SELECT EXISTS(SELECT 1 FROM pg_database WHERE datname = ?)", dbName,
	).Scan(&exists).Error; err != nil {
		return fmt.Errorf("بررسی وجود دیتابیس ناموفق بود: %w", err)
	}

	if !exists {
		log.Printf("دیتابیس %q یافت نشد - در حال ساخت خودکار...", dbName)
		if err := maintenanceConn.Exec(fmt.Sprintf(`CREATE DATABASE %q`, dbName)).Error; err != nil {
			return fmt.Errorf("ساخت خودکار دیتابیس ناموفق بود: %w", err)
		}
	}
	return nil
}

// runMigrations اسکیمای دیتابیس رو با مدل‌های فعلی همگام می‌کنه. چون AutoMigrate
// ستون‌های حذف‌شده رو خودش drop نمی‌کنه، ستون‌های منسوخ‌شده صریحاً قبل از
// AutoMigrate حذف می‌شن.
func runMigrations(connection *gorm.DB) error {
	migrator := connection.Migrator()

	// priority قبلاً برای تعیین محتوای ویترین استفاده می‌شد؛ با سیستم
	// vitrine_items (پین کردن محتوا به اسلات مشخص) جایگزین شده.
	if migrator.HasTable(&Models.Content{}) && migrator.HasColumn(&Models.Content{}, "Priority") {
		if err := migrator.DropColumn(&Models.Content{}, "Priority"); err != nil {
			return fmt.Errorf("حذف ستون priority ناموفق بود: %w", err)
		}
	}

	return connection.AutoMigrate(
		&Models.User{},
		&Models.Device{},
		&Models.Content{},
		&Models.ContentImage{},
		&Models.DeviceContent{},
		&Models.VitrineItem{},
		&Models.UserDevice{},
	)
}
