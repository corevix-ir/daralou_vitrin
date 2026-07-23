package Scraper

import (
	"Back/Models"
	"Back/Repositories"
	"fmt"
	"github.com/gocolly/colly/v2"
	"log"
	"strings"
)

type news struct {
	Title        string
	Body         string
	Summary      string
	MainImageURL string
	ExternalURL  string
}

type ScrapCollyService interface {
	ScrapDaralouNews() error
	DownloadImageNews(linkImage string) error
}

type scrapCollyService struct {
	contentRepo   Repositories.ContentRepository
	collector     *colly.Collector
	baseImagePath string
}

func NewScrapCollyService(
	contentRepo Repositories.ContentRepository,
	collector *colly.Collector, baseImagePath string) ScrapCollyService {
	return &scrapCollyService{
		contentRepo:   contentRepo,
		collector:     collector,
		baseImagePath: baseImagePath}
}

func (s *scrapCollyService) ScrapDaralouNews() error {
	base := s.collector
	listCollector := base.Clone()
	detailCollector := base.Clone()

	var urls []string

	// جلوگیری از اجرای دوباره handler ها اگر چند بار صدا زده شود
	detailCollector.OnHTML(".es-post-header", func(e *colly.HTMLElement) {

		title := strings.TrimSpace(
			e.ChildText(".news-head h2"),
		)

		// گرفتن HTML اصلی محتوا
		bodyHTML, err := e.DOM.Find(".news-content").Html()
		if err != nil {
			log.Println("body html error:", err)
			return
		}

		// اینجا ذخیره دیتابیس
		content := Models.Content{
			ContentType: Models.ContentTypeNews,
			Title:       title,
			Body:        bodyHTML,
			//MainImageURL: image,
			ExternalURL: e.Request.URL.String(),
			Source:      Models.SourceDaralou,
		}

		if err1 := s.contentRepo.CreateContent(&content); err1 != nil {
			return
		}

	})

	// صفحه لیست اخبار
	listCollector.OnHTML("article.es-post-item", func(e *colly.HTMLElement) {

		href := e.ChildAttr(
			".es-post-title a",
			"href",
		)

		url := e.Request.AbsoluteURL(href)
		exist, _ := s.contentRepo.ExistsBySource(Models.SourceDaralou, url)
		if exist {
			fmt.Println("Already exists:", url)
			return
		}
		urls = append(urls, url)

	})

	for page := 2; page <= 2; page++ {
		url := fmt.Sprintf("https://daralou.nicico.com/اخبار/صفحه:%d", page)
		fmt.Println("PAGE:", url)
		err := listCollector.Visit(url)
		if err != nil {
			return err
		}
	}

	for _, url := range urls {

		err := detailCollector.Visit(url)
		if err != nil {
			log.Println("detail visit error:", err)
		}
	}

	return nil
}

func (s *scrapCollyService) DownloadImageNews(linkImage string) error {

	return nil
}
