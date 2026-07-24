package Scraper

import (
	"github.com/robfig/cron/v3"
	"log"
)

func StartScraperScheduler(scraperService ScrapCollyService) {
	c := cron.New(
		cron.WithChain(
			// اگر اجرای قبلی هنوز تمام نشده بود، اجرای جدید را رد می‌کند
			cron.SkipIfStillRunning(cron.DefaultLogger),
		),
	)

	// هر 10 دقیقه
	_, err := c.AddFunc("*/10 * * * *", func() {
		log.Println("[SCRAPER] Daralou started")

		if err := scraperService.ScrapDaralouNews(); err != nil {
			log.Println("[SCRAPER] Daralou error:", err)
			return
		}

		log.Println("[SCRAPER] Daralou finished")
	})

	if err != nil {
		log.Fatal(err)
	}

	c.Start()
}
