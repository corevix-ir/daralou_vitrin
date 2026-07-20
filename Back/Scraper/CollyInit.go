package Scraper

import (
	"bytes"
	"fmt"
	"time"

	"github.com/PuerkitoBio/goquery"
	"github.com/gocolly/colly/v2"
)

type Config struct {
	BaseURL      string        // مثال: https://daralou.nicico.com
	ListPath     string        // الگوی مسیر لیست با %d ؛ مثال: "/اخبار/صفحه:%d"
	UserAgent    string        // شناسهٔ مرورگر
	RequestDelay time.Duration // فاصلهٔ بین درخواست‌ها (فشار نیاوردن به سایت)
	Timeout      time.Duration // مهلتِ هر درخواست
	MaxRetries   int           // تعداد تلاش مجدد در خطا
}

// DefaultConfig مقادیر پیش‌فرضِ منطقی (قابل بازنویسی از env).
func DefaultConfig() Config {
	return Config{
		BaseURL:      "https://daralou.nicico.com",
		ListPath:     "/اخبار/صفحه:%d",
		UserAgent:    "SignageBot/1.0 (+internal news mirror)",
		RequestDelay: 2 * time.Second,
		Timeout:      20 * time.Second,
		MaxRetries:   2,
	}
}

// Scraper مسئولِ فچِ صفحات با colly است. پارس به توابعِ تست‌شدهٔ
// ParseListPage/ParseDetailPage واگذار می‌شود.
type Scraper struct {
	cfg Config
}

func New(cfg Config) *Scraper {
	if cfg.BaseURL == "" {
		cfg = DefaultConfig()
	}
	return &Scraper{cfg: cfg}
}

// newCollector یک collector تازه با تنظیماتِ محدودیت و تایم‌اوت می‌سازد.
func (s *Scraper) newCollector() *colly.Collector {
	c := colly.NewCollector(
		colly.UserAgent(s.cfg.UserAgent),
		colly.MaxDepth(1),
	)
	c.SetRequestTimeout(s.cfg.Timeout)
	_ = c.Limit(&colly.LimitRule{
		DomainGlob:  "*",
		Delay:       s.cfg.RequestDelay,
		Parallelism: 1,
	})
	return c
}

// fetchDoc یک URL را می‌گیرد و به goquery.Document تبدیل می‌کند.
// از colly برای throttle/retry/UA استفاده می‌شود؛ خودِ پارس با goquery.
func (s *Scraper) fetchDoc(url string) (*goquery.Document, error) {
	c := s.newCollector()

	var body []byte
	var fetchErr error

	c.OnResponse(func(r *colly.Response) {
		body = append([]byte(nil), r.Body...)
	})
	c.OnError(func(r *colly.Response, err error) {
		fetchErr = fmt.Errorf("fetch %s: status=%d: %w", url, r.StatusCode, err)
	})

	if err := c.Visit(url); err != nil {
		return nil, fmt.Errorf("visit %s: %w", url, err)
	}
	c.Wait()

	if fetchErr != nil {
		return nil, fetchErr
	}
	if len(body) == 0 {
		return nil, fmt.Errorf("empty body from %s", url)
	}

	doc, err := goquery.NewDocumentFromReader(bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("parse html %s: %w", url, err)
	}
	return doc, nil
}

// FetchListPage صفحهٔ شمارهٔ page از لیست اخبار را می‌گیرد و آیتم‌ها را برمی‌گرداند.
// اگر آیتمی نداشت (لیست خالی)، اسلایسِ خالی برمی‌گردد (خطا نیست).
func (s *Scraper) FetchListPage(page int) ([]ListItem, error) {
	url := s.cfg.BaseURL + fmt.Sprintf(s.cfg.ListPath, page)
	doc, err := s.fetchDoc(url)
	if err != nil {
		return nil, err
	}
	return ParseListPage(doc), nil
}

// FetchDetail صفحهٔ تک‌خبر را می‌گیرد و محتوای کامل را پارس می‌کند.
func (s *Scraper) FetchDetail(detailURL string) (*NewsDetail, error) {
	doc, err := s.fetchDoc(detailURL)
	if err != nil {
		return nil, err
	}
	return ParseDetailPage(doc), nil
}
