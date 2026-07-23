package config

import (
	"github.com/gocolly/colly/v2"
	"github.com/joho/godotenv"
	"log"
	"os"
	"sync"
)

type CollyScraper struct {
	Collector     *colly.Collector
	BaseImagePath string
}

var (
	c             *colly.Collector
	baseImagePath string
	once1         sync.Once
)

func GetCollyScraper() *CollyScraper {
	once1.Do(func() {
		initializeCollector()
	})
	return &CollyScraper{
		Collector:     c,
		BaseImagePath: baseImagePath,
	}
}

func initializeCollector() {
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("Error loading .env file %v", err)
	}

	// خواندن مشخصات scraper از متغیرهای محیطی
	//allowedDomains := os.Getenv("ALLOWED_DOMAINS")
	baseImagePath = os.Getenv("BASE_IMAGE_PATH")

	c = colly.NewCollector(
		colly.UserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"),
		colly.MaxDepth(3),
		//colly.MaxBodySize(15),
		//colly.AllowedDomains(allowedDomains),
		colly.IgnoreRobotsTxt(),
	)

	/*
		err1 := c.Limit(&colly.LimitRule{
			Delay:       3 * time.Second,
			RandomDelay: 2 * time.Second,
		})
		if err1 != nil {
			log.Fatal(errors.New("error setting limit" + err1.Error()))
		}

	*/
}
