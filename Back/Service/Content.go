package Services

import (
	"Back/DTO"
	"Back/Models"
	"Back/Repositories"
	"errors"
	"time"
)

// فعلا content_type محتوای دستی ثابته - طبق تایید
const manualContentType = "announcement"

type ContentService interface {
	CreateContent(userID uint, request DTO.CreateContent) error
	GetVitrinList(deviceID uint) (DTO.VitrinContentList, error)
	GetScrapContentList(page, size int) (contentList DTO.ContentList, err error)
	GetLocalContentList(deviceID uint, page, size int) (contentList DTO.ContentList, err error)
	GetDetailsContent(contentID, deviceID uint) (DTO.ContentInfo, error)
	UpdateContent(id uint, request DTO.UpdateContentRequest) error
	DeleteContent(id uint) error
}

type contentService struct {
	Repository Repositories.ContentRepository
}

func NewContentService(contentRepo Repositories.ContentRepository) ContentService {
	return &contentService{
		Repository: contentRepo,
	}
}

func (s *contentService) CreateContent(userID uint, content DTO.CreateContent) error {
	tx := s.Repository.BeginTransaction()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	txRepo := s.Repository.WithTransaction(tx)

	newContent := &Models.Content{
		ContentType:  manualContentType,
		Title:        content.Title,
		Body:         content.Body,
		Summary:      content.Summary,
		Priority:     content.Priority,
		MainImageURL: content.MainImg,
		Source:       Models.SourceLocal,
		StartDate:    content.StartDate,
		EndDate:      content.EndDate,
		IsPublished:  true,
		CreatedBy:    &userID,
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	}

	if err := txRepo.CreateContent(newContent); err != nil {
		tx.Rollback()
		return errors.New("خطا در ایجاد محتوا جدید: " + err.Error())
	}

	for i, img := range content.ImgList {
		newContentImage := &Models.ContentImage{
			ContentID:  newContent.ID,
			ImageURL:   img,
			ImageOrder: i,
			CreatedAt:  time.Now(),
		}
		if err := txRepo.CreateImageContent(newContentImage); err != nil {
			tx.Rollback()
			return errors.New("خطا در ذخیره تصاویر محتوا: " + err.Error())
		}
	}

	// اتصال محتوای دستی به دستگاه ها
	for _, deviceID := range content.DeviceID {
		if err := txRepo.AssignContentToDevice(deviceID, newContent.ID); err != nil {
			tx.Rollback()
			return errors.New("خطا در تخصیص محتوا به دستگاه: " + err.Error())
		}
	}

	if err := tx.Commit().Error; err != nil {
		tx.Rollback()
		return errors.New("خطا در تایید تراکنش: " + err.Error())
	}

	return nil
}

func (s *contentService) GetVitrinList(deviceID uint) (DTO.VitrinContentList, error) {
	var result DTO.VitrinContentList

	// ۵ خبر آخر اسکرپ‌شده - برای همه دستگاه‌ها یکسان
	scrapContents, err := s.Repository.GetLatestContentsBySource(Models.SourceDaralou, 5)
	if err != nil {
		return result, errors.New("خطا در دریافت اخبار اسکرپ شده: " + err.Error())
	}
	result.Scrap = toSummaryList(scrapContents)

	// محتوای اختصاصی دستگاه با priority=1
	localContents, err1 := s.Repository.GetContentsByDeviceAndPriority(deviceID, 1)
	if err1 != nil {
		return result, errors.New("خطا در دریافت محتوای اختصاصی دستگاه: " + err1.Error())
	}
	result.Local = toSummaryList(localContents)

	return result, nil
}

func (s *contentService) GetScrapContentList(page, size int) (DTO.ContentList, error) {
	var result DTO.ContentList
	offset, limit := paginate(page, size)

	contents, err := s.Repository.GetContentsBySource(Models.SourceDaralou, offset, limit)
	if err != nil {
		return result, errors.New("خطا در دریافت لیست اخبار: " + err.Error())
	}
	result.SummaryContent = toSummaryList(contents)
	return result, nil
}

func (s *contentService) GetLocalContentList(deviceID uint, page, size int) (DTO.ContentList, error) {
	var result DTO.ContentList
	offset, limit := paginate(page, size)

	contents, err := s.Repository.GetContentsByDevice(deviceID, offset, limit)
	if err != nil {
		return result, errors.New("خطا در دریافت محتوای دستگاه: " + err.Error())
	}
	result.SummaryContent = toSummaryList(contents)

	return result, nil
}

func (s *contentService) GetDetailsContent(contentID, deviceID uint) (DTO.ContentInfo, error) {
	var info DTO.ContentInfo

	content, err := s.Repository.GetByIDContent(contentID)
	if err != nil {
		return info, errors.New("محتوا یافت نشد")
	}

	if content.Source == Models.SourceLocal {
		assigned, err1 := s.Repository.IsContentAssignedToDevice(deviceID, contentID)
		if err1 != nil {
			return info, errors.New("مشکل در چک کردن دسترسی به محتوا" + err1.Error())
		}
		if !assigned {
			return info, errors.New("این دستگاه دسترسی به این محتوا ندارد! ")
		}
	}

	images, err1 := s.Repository.GetImagesByContentID(content.ID)
	if err1 != nil {
		return info, errors.New("خطا در دریافت تصاویر محتوا: " + err1.Error())
	}

	imgUrls := make([]string, len(images))
	for i, img := range images {
		imgUrls[i] = img.ImageURL
	}

	summary := ""
	if content.Summary != nil {
		summary = *content.Summary
	}

	info = DTO.ContentInfo{
		ID:           content.ID,
		ContentType:  content.ContentType,
		Title:        content.Title,
		Body:         content.Body,
		Summary:      summary,
		MainImageURL: content.MainImageURL,
		ExtraImgList: imgUrls,
		ExternalURL:  content.ExternalURL,
		Source:       content.Source,
		Priority:     content.Priority,
		StartDate:    content.StartDate,
		EndDate:      content.EndDate,
		IsPublished:  content.IsPublished,
		CreatedBy:    content.CreatedBy,
		CreatedAt:    content.CreatedAt,
		UpdatedAt:    content.UpdatedAt,
	}

	return info, nil
}

func (s *contentService) UpdateContent(id uint, request DTO.UpdateContentRequest) error {
	content, err := s.Repository.GetByIDContent(id)
	if err != nil {
		return errors.New("محتوا یافت نشد")
	}

	if content.Source == Models.SourceDaralou {
		return errors.New("محتوا اسکرپ شده قابل تغییر نیست! ")
	}

	updates := map[string]interface{}{}

	if request.Title != nil {
		updates["title"] = *request.Title
	}
	if request.Body != nil {
		updates["body"] = *request.Body
	}
	if request.Summary != nil {
		updates["summary"] = *request.Summary
	}
	if request.Priority != nil {
		updates["priority"] = *request.Priority
	}
	if request.MainImg != nil {
		updates["main_image_url"] = *request.MainImg
	}
	if request.StartDate != nil {
		updates["start_date"] = *request.StartDate
	}
	if request.EndDate != nil {
		updates["end_date"] = *request.EndDate
	}

	if len(updates) > 0 {
		updates["updated_at"] = time.Now()
		if err = s.Repository.UpdateContent(id, updates); err != nil {
			return errors.New("خطا در آپدیت محتوا: " + err.Error())
		}
	}

	if request.ImgList != nil {
		tx := s.Repository.BeginTransaction()
		defer func() {
			if r := recover(); r != nil {
				tx.Rollback()
			}
		}()
		txRepo := s.Repository.WithTransaction(tx)

		if err = txRepo.DeleteImagesByContentID(id); err != nil {
			tx.Rollback()
			return errors.New("خطا در حذف تصاویر قبلی: " + err.Error())
		}

		for i, img := range *request.ImgList {
			newImg := &Models.ContentImage{
				ContentID:  id,
				ImageURL:   img,
				ImageOrder: i,
				CreatedAt:  time.Now(),
			}
			if err = txRepo.CreateImageContent(newImg); err != nil {
				tx.Rollback()
				return errors.New("خطا در ذخیره تصاویر جدید: " + err.Error())
			}
		}

		if err = tx.Commit().Error; err != nil {
			tx.Rollback()
			return errors.New("خطا در تایید تراکنش: " + err.Error())
		}
	}

	return nil
}

func (s *contentService) DeleteContent(id uint) error {
	content, err := s.Repository.GetByIDContent(id)
	if err != nil {
		return errors.New("محتوا یافت نشد")
	}

	if content.Source == Models.SourceDaralou {
		return errors.New("محتوا اسکرپ شده قابل تغییر نیست! ")
	}

	tx := s.Repository.BeginTransaction()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()
	txRepo := s.Repository.WithTransaction(tx)

	if err = txRepo.DeleteImagesByContentID(id); err != nil {
		tx.Rollback()
		return errors.New("خطا در حذف تصاویر محتوا: " + err.Error())
	}

	if err = txRepo.DeleteContent(id); err != nil {
		tx.Rollback()
		return errors.New("خطا در حذف محتوا: " + err.Error())
	}

	if err = tx.Commit().Error; err != nil {
		tx.Rollback()
		return errors.New("خطا در تایید تراکنش: " + err.Error())
	}

	return nil
}

// ============================ Helpers ============================

func paginate(page, size int) (offset, limit int) {
	if page < 1 {
		page = 1
	}
	if size < 1 || size > 100 {
		size = 20
	}
	return (page - 1) * size, size
}

func toSummaryList(contents []Models.Content) []DTO.SummaryContent {
	list := make([]DTO.SummaryContent, len(contents))
	for i, c := range contents {
		list[i] = DTO.SummaryContent{
			ID:        c.ID,
			Title:     c.Title,
			Summary:   c.Summary,
			MainImg:   c.MainImageURL,
			CreatedAt: c.CreatedAt,
		}
	}
	return list
}
