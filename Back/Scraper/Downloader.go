package Scraper

import (
	"crypto/sha1"
	"encoding/hex"
	"fmt"
	"io"
	"net/http"
	"os"
	"path"
	"path/filepath"
	"strings"
	"time"
)

// DownloaderConfig تنظیماتِ ذخیرهٔ عکس روی سرورِ خودمان.
type DownloaderConfig struct {
	StorageDir string        // مسیر لوکالِ ذخیره؛ مثال: /var/www/media/news
	PublicBase string        // آدرسِ عمومیِ سرورِ ما؛ مثال: https://signage.local/media/news
	Timeout    time.Duration // مهلتِ دانلود هر فایل
	UserAgent  string
}

// Downloader فایل‌ها را از سایت مبدأ دانلود و روی سرورِ ما ذخیره می‌کند.
type Downloader struct {
	cfg    DownloaderConfig
	client *http.Client
}

func NewDownloader(cfg DownloaderConfig) *Downloader {
	if cfg.Timeout == 0 {
		cfg.Timeout = 30 * time.Second
	}
	if cfg.UserAgent == "" {
		cfg.UserAgent = "SignageBot/1.0"
	}
	return &Downloader{
		cfg:    cfg,
		client: &http.Client{Timeout: cfg.Timeout},
	}
}

// allowedExt پسوندهای تصویریِ مجاز.
var allowedExt = map[string]bool{
	".jpg": true, ".jpeg": true, ".png": true, ".webp": true, ".gif": true,
}

// localName یک نامِ فایلِ یکتا و امن از روی آدرس مبدأ می‌سازد:
// {prefix}_{sha1[:12]}{ext}. برخوردِ نام غیرممکن و idempotent است
// (همان آدرس همیشه همان نام) تا دانلودِ دوباره رخ ندهد.
func localName(prefix, srcURL string) string {
	sum := sha1.Sum([]byte(srcURL))
	hash := hex.EncodeToString(sum[:])[:12]

	ext := strings.ToLower(path.Ext(path.Base(strings.SplitN(srcURL, "?", 2)[0])))
	if !allowedExt[ext] {
		ext = ".jpg" // پیش‌فرضِ امن
	}
	prefix = strings.TrimSpace(prefix)
	if prefix == "" {
		prefix = "img"
	}
	return fmt.Sprintf("%s_%s%s", prefix, hash, ext)
}

// Download یک فایل را دانلود و ذخیره می‌کند و آدرسِ عمومیِ سرورِ ما را برمی‌گرداند.
// اگر فایل از قبل موجود باشد، دوباره دانلود نمی‌کند (idempotent).
func (d *Downloader) Download(srcURL, prefix string) (string, error) {
	if srcURL == "" {
		return "", fmt.Errorf("empty source url")
	}

	name := localName(prefix, srcURL)
	destPath := filepath.Join(d.cfg.StorageDir, name)
	publicURL := strings.TrimRight(d.cfg.PublicBase, "/") + "/" + name

	// اگر قبلاً دانلود شده، همان را برگردان.
	if _, err := os.Stat(destPath); err == nil {
		return publicURL, nil
	}

	if err := os.MkdirAll(d.cfg.StorageDir, 0o755); err != nil {
		return "", fmt.Errorf("mkdir %s: %w", d.cfg.StorageDir, err)
	}

	req, err := http.NewRequest(http.MethodGet, srcURL, nil)
	if err != nil {
		return "", fmt.Errorf("new request: %w", err)
	}
	req.Header.Set("User-Agent", d.cfg.UserAgent)

	resp, err := d.client.Do(req)
	if err != nil {
		return "", fmt.Errorf("download %s: %w", srcURL, err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("download %s: status %d", srcURL, resp.StatusCode)
	}

	// نوشتن روی فایلِ موقت و سپس rename اتمیک (تا فایلِ ناقص باقی نماند).
	tmp := destPath + ".tmp"
	f, err := os.Create(tmp)
	if err != nil {
		return "", fmt.Errorf("create %s: %w", tmp, err)
	}
	if _, err := io.Copy(f, resp.Body); err != nil {
		f.Close()
		os.Remove(tmp)
		return "", fmt.Errorf("write %s: %w", tmp, err)
	}
	f.Close()

	if err := os.Rename(tmp, destPath); err != nil {
		os.Remove(tmp)
		return "", fmt.Errorf("rename %s: %w", destPath, err)
	}

	return publicURL, nil
}
