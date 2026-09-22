package Services

import (
	"errors"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"time"
)

const maxImageUploadSize = 5 << 20 // 5MB

var imageExtByMime = map[string]string{
	"image/jpeg": ".jpg",
	"image/png":  ".png",
	"image/gif":  ".gif",
	"image/webp": ".webp",
}

type UploadService interface {
	SaveImage(fileHeader *multipart.FileHeader) (publicURL string, err error)
}

type uploadService struct {
	baseImagePath string
}

func NewUploadService(baseImagePath string) UploadService {
	return &uploadService{baseImagePath: baseImagePath}
}

// SaveImage محتوای فایل رو (بعد از چک نوع/حجم) داخل پوشه‌ی uploads ذخیره می‌کنه
// و URL عمومی قابل‌استفاده در main_img/img_list محتوا رو برمی‌گردونه. اسم فایل
// خودش تولید می‌شه (نه از روی نام فرستاده‌شده توسط کلاینت) تا از تداخل/مسیر
// نامعتبر جلوگیری بشه - مشابه همین الگو در Scraper/NewsDaralou.go.
func (s *uploadService) SaveImage(fileHeader *multipart.FileHeader) (string, error) {
	if fileHeader.Size > maxImageUploadSize {
		return "", errors.New("حجم تصویر نباید بیشتر از ۵ مگابایت باشد")
	}

	src, err := fileHeader.Open()
	if err != nil {
		return "", errors.New("باز کردن فایل ناموفق بود: " + err.Error())
	}
	defer src.Close()

	sniff := make([]byte, 512)
	n, err := src.Read(sniff)
	if err != nil && err != io.EOF {
		return "", errors.New("خواندن فایل ناموفق بود: " + err.Error())
	}

	ext, ok := imageExtByMime[http.DetectContentType(sniff[:n])]
	if !ok {
		return "", errors.New("فرمت تصویر پشتیبانی نمی‌شود (فقط jpg/png/gif/webp مجاز است)")
	}

	if _, err = src.Seek(0, io.SeekStart); err != nil {
		return "", errors.New("پردازش فایل ناموفق بود: " + err.Error())
	}

	folder := filepath.Join(s.baseImagePath, "uploads")
	if err = os.MkdirAll(folder, 0755); err != nil {
		return "", errors.New("ساخت پوشه‌ی آپلود ناموفق بود: " + err.Error())
	}

	fileName := fmt.Sprintf("%d%s", time.Now().UnixNano(), ext)
	filePath := filepath.Join(folder, fileName)

	dst, err := os.Create(filePath)
	if err != nil {
		return "", errors.New("ذخیره‌ی فایل ناموفق بود: " + err.Error())
	}
	defer dst.Close()

	if _, err = io.Copy(dst, src); err != nil {
		return "", errors.New("نوشتن فایل ناموفق بود: " + err.Error())
	}

	return "/static/uploads/" + fileName, nil
}
