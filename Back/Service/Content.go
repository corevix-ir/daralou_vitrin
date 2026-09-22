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
	GetAssignedDeviceIDs(contentID uint) ([]uint, error)
}

type contentService struct {
	Repository        Repositories.ContentRepository
	VitrineRepository Repositories.VitrineRepository
	DeviceRepository  Repositories.DeviceRepository
	baseImagePath     string
}

func NewContentService(
	contentRepo Repositories.ContentRepository,
	vitrineRepo Repositories.VitrineRepository,
	deviceRepo Repositories.DeviceRepository,
	baseImagePath string,
) ContentService {
	return &contentService{
		Repository:        contentRepo,
		VitrineRepository: vitrineRepo,
		DeviceRepository:  deviceRepo,
		baseImagePath:     baseImagePath,
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

// GetVitrinList ویترین این دستگاه رو می‌سازه: اول اسلات‌هایی که ادمین صریحاً
// پین کرده (از هر دو منبع لوکال/اسکرپ) رو در جایگاه position خودشون قرار
// می‌ده، بعد اسلات‌های خالی باقی‌مونده رو با آخرین اخبار اسکرپ‌شده (که قبلاً
// پین نشده باشن) پر می‌کنه. اگه هیچ‌چیز پین نشده باشه، کل ویترین خودکار از
// اخبار پر می‌شه؛ اگه همه‌ی اسلات‌ها پین شده باشن، هیچ خبری اضافه نمی‌شه.
func (s *contentService) GetVitrinList(deviceID uint) (DTO.VitrinContentList, error) {
	var result DTO.VitrinContentList

	device, err := s.DeviceRepository.GetByIDDevice(deviceID)
	if err != nil {
		return result, errors.New("دستگاه یافت نشد")
	}
	size := device.VitrineSize
	if size < 1 {
		size = 1
	}

	pinned, err := s.VitrineRepository.GetItemsByDevice(deviceID)
	if err != nil {
		return result, errors.New("خطا در دریافت تنظیمات ویترین: " + err.Error())
	}

	slots := make([]*DTO.VitrineSlot, size+1) // 1-indexed
	usedIDs := make([]uint, 0, len(pinned))
	for _, item := range pinned {
		if item.Position < 1 || item.Position > size {
			continue
		}
		slots[item.Position] = &DTO.VitrineSlot{
			Position: item.Position,
			Source:   item.Content.Source,
			IsAuto:   false,
			Content:  s.toSummaryContent(item.Content),
		}
		usedIDs = append(usedIDs, item.ContentID)
	}

	emptyPositions := make([]int, 0, size)
	for pos := 1; pos <= size; pos++ {
		if slots[pos] == nil {
			emptyPositions = append(emptyPositions, pos)
		}
	}

	if len(emptyPositions) > 0 {
		news, err := s.Repository.GetLatestContentsBySourceExcluding(Models.SourceDaralou, usedIDs, len(emptyPositions))
		if err != nil {
			return result, errors.New("خطا در دریافت اخبار اسکرپ شده: " + err.Error())
		}
		for i, pos := range emptyPositions {
			if i >= len(news) {
				break
			}
			slots[pos] = &DTO.VitrineSlot{
				Position: pos,
				Source:   news[i].Source,
				IsAuto:   true,
				Content:  s.toSummaryContent(news[i]),
			}
		}
	}

	items := make([]DTO.VitrineSlot, 0, size)
	for pos := 1; pos <= size; pos++ {
		if slots[pos] != nil {
			items = append(items, *slots[pos])
		}
	}
	result.Items = items

	return result, nil
}

func (s *contentService) GetScrapContentList(page, size int) (DTO.ContentList, error) {
	var result DTO.ContentList
	offset, limit := paginate(page, size)

	contents, err := s.Repository.GetContentsBySource(Models.SourceDaralou, offset, limit)
	if err != nil {
		return result, errors.New("خطا در دریافت لیست اخبار: " + err.Error())
	}
	total, err := s.Repository.CountContentsBySource(Models.SourceDaralou)
	if err != nil {
		return result, errors.New("خطا در شمارش لیست اخبار: " + err.Error())
	}
	result.SummaryContent = s.toSummaryList(contents)
	result.Total = total
	result.Page = page
	result.Size = size
	return result, nil
}

func (s *contentService) GetLocalContentList(deviceID uint, page, size int) (DTO.ContentList, error) {
	var result DTO.ContentList
	offset, limit := paginate(page, size)

	contents, err := s.Repository.GetContentsByDevice(deviceID, offset, limit)
	if err != nil {
		return result, errors.New("خطا در دریافت محتوای دستگاه: " + err.Error())
	}
	total, err := s.Repository.CountContentsByDevice(deviceID)
	if err != nil {
		return result, errors.New("خطا در شمارش محتوای دستگاه: " + err.Error())
	}
	result.SummaryContent = s.toSummaryList(contents)
	result.Total = total
	result.Page = page
	result.Size = size

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
		imgUrls[i] = ToPublicImageURL(s.baseImagePath, img.ImageURL)
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
		MainImageURL: ToPublicImageURL(s.baseImagePath, content.MainImageURL),
		ExtraImgList: imgUrls,
		ExternalURL:  content.ExternalURL,
		Source:       content.Source,
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

// GetAssignedDeviceIDs لیست دستگاه‌هایی که این محتوا بهشون اساین شده رو
// برمی‌گردونه - برای چک دسترسیِ اپراتور (باید مالک همه‌ی این دستگاه‌ها باشه).
func (s *contentService) GetAssignedDeviceIDs(contentID uint) ([]uint, error) {
	return s.Repository.GetDeviceIDsByContent(contentID)
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

func (s *contentService) toSummaryList(contents []Models.Content) []DTO.SummaryContent {
	list := make([]DTO.SummaryContent, len(contents))
	for i, c := range contents {
		list[i] = s.toSummaryContent(c)
	}
	return list
}

func (s *contentService) toSummaryContent(c Models.Content) DTO.SummaryContent {
	return DTO.SummaryContent{
		ID:        c.ID,
		Title:     c.Title,
		Summary:   c.Summary,
		MainImg:   ToPublicImageURL(s.baseImagePath, c.MainImageURL),
		CreatedAt: c.CreatedAt,
	}
}
