package Scraper

import (
	"Back/Models"
	"Back/Repositories"
	"fmt"
	"github.com/PuerkitoBio/goquery"
	"github.com/gocolly/colly/v2"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"
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
	DownloadAsset(linkImage string) (string, error)
	ProcessHTMLAssets(html string, contentID uint) (string, error)
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
	stop := false

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

		// عکس اصلی خبر
		mainImage := e.ChildAttr(
			".es-post-thumb img",
			"src",
		)
		mainImage = e.Request.AbsoluteURL(mainImage)
		localImage, err1 := s.DownloadAsset(mainImage)
		if err1 != nil {
			log.Println("main image download error:", err1)
		}

		// اینجا ذخیره دیتابیس
		content := Models.Content{
			ContentType:  Models.ContentTypeNews,
			Title:        title,
			Body:         bodyHTML,
			MainImageURL: localImage,
			ExternalURL:  e.Request.URL.String(),
			Source:       Models.SourceDaralou,
		}

		if err1 = s.contentRepo.CreateContent(&content); err1 != nil {
			return
		}

		// دانلود فایل های داخل متن
		bodyHTML, err = s.ProcessHTMLAssets(bodyHTML, content.ID)
		if err != nil {
			log.Println("asset process error:", err)
		}

	})

	// صفحه لیست اخبار
	listCollector.OnHTML("article.es-post-item", func(e *colly.HTMLElement) {

		if stop {
			return
		}

		href := e.ChildAttr(
			".es-post-title a",
			"href",
		)

		url := e.Request.AbsoluteURL(href)
		exist, _ := s.contentRepo.ExistsBySource(Models.SourceDaralou, url)
		if exist {
			fmt.Println("Already exists:", url)
			stop = true
			return
		}
		urls = append(urls, url)

	})

	for page := 1; page <= 10 && !stop; page++ {
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

// DownloadAsset دانلود فایل با http
func (s *scrapCollyService) DownloadAsset(linkImage string) (string, error) {

	if linkImage == "" {
		return "", nil
	}

	resp, err := http.Get(linkImage)
	if err != nil {
		return "", err
	}

	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return "", fmt.Errorf(
			"download failed status %d",
			resp.StatusCode,
		)
	}

	ext := filepath.Ext(linkImage)
	if ext == "" {
		ext = ".jpg"
	}

	fileName := fmt.Sprintf("%d%s", time.Now().UnixNano(), ext)

	folder := filepath.Join(s.baseImagePath, "news")

	if err = os.MkdirAll(folder, 0755); err != nil {
		return "", err
	}

	filePath := filepath.Join(folder, fileName)
	file, err := os.Create(filePath)

	if err != nil {

		return "", err
	}

	defer file.Close()

	_, err = io.Copy(file, resp.Body)

	if err != nil {
		return "", err
	}

	// مسیر عمومیِ قابل‌سرو از طریق /static (نه مسیر مطلق فایل‌سیستم که filePath
	// نگه می‌داره - همون قراردادی که Service/Upload.go برای آپلود دستی استفاده می‌کنه).
	return "/static/news/" + fileName, nil

}

// ProcessHTMLAssets : پردازش عکس و ویدیو داخل بادی
func (s *scrapCollyService) ProcessHTMLAssets(html string, contentID uint) (string, error) {

	doc, err := goquery.NewDocumentFromReader(
		strings.NewReader(html),
	)

	if err != nil {
		return "", err
	}

	// -----------------------
	// Images
	// -----------------------

	doc.Find("img").Each(func(i int, selection *goquery.Selection) {

		src, exists := selection.Attr("src")

		if !exists || src == "" {
			return
		}

		local, err1 := s.DownloadAsset(src)

		if err1 == nil {
			selection.SetAttr("src", local)
		}

	})

	// -----------------------
	// Video / Audio source
	// -----------------------

	doc.Find("video source, audio source").Each(func(i int, selection *goquery.Selection) {

		src, exists := selection.Attr("src")

		if !exists || src == "" {
			return
		}

		local, err1 := s.DownloadAsset(src)

		if err1 == nil {
			selection.SetAttr("src", local)
		}

	})

	// -----------------------
	// فایل‌ها مثل PDF
	// -----------------------

	doc.Find("a[href]").Each(func(i int, selection *goquery.Selection) {

		href, exists := selection.Attr("href")

		if !exists || href == "" {
			return
		}

		ext := strings.ToLower(filepath.Ext(href))

		switch ext {
		case ".pdf", ".doc", ".docx", ".zip":
			local, err1 := s.DownloadAsset(href)
			if err1 == nil {
				selection.SetAttr("href", local)
			}
		}

	})

	return doc.Html()
}
