package config

import (
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

	db = connection
}
