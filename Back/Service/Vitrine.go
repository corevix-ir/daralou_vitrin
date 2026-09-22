package Services

import (
	"Back/DTO"
	"Back/Models"
	"Back/Repositories"
	"errors"
	"fmt"
)

type VitrineService interface {
	GetConfig(deviceID uint) (DTO.VitrineConfig, error)
	ReplaceConfig(deviceID uint, request DTO.ReplaceVitrineConfigRequest) error
}

type vitrineService struct {
	VitrineRepository Repositories.VitrineRepository
	ContentRepository Repositories.ContentRepository
	DeviceRepository  Repositories.DeviceRepository
	baseImagePath     string
}

func NewVitrineService(
	vitrineRepo Repositories.VitrineRepository,
	contentRepo Repositories.ContentRepository,
	deviceRepo Repositories.DeviceRepository,
	baseImagePath string,
) VitrineService {
	return &vitrineService{
		VitrineRepository: vitrineRepo,
		ContentRepository: contentRepo,
		DeviceRepository:  deviceRepo,
		baseImagePath:     baseImagePath,
	}
}

func (s *vitrineService) GetConfig(deviceID uint) (DTO.VitrineConfig, error) {
	var result DTO.VitrineConfig

	device, err := s.DeviceRepository.GetByIDDevice(deviceID)
	if err != nil {
		return result, errors.New("دستگاه یافت نشد")
	}
	result.Size = device.VitrineSize

	items, err := s.VitrineRepository.GetItemsByDevice(deviceID)
	if err != nil {
		return result, errors.New("خطا در دریافت تنظیمات ویترین: " + err.Error())
	}

	result.Items = make([]DTO.VitrineItemDetail, len(items))
	for i, item := range items {
		result.Items[i] = DTO.VitrineItemDetail{
			Position: item.Position,
			Source:   item.Content.Source,
			Content: DTO.SummaryContent{
				ID:        item.Content.ID,
				Title:     item.Content.Title,
				Summary:   item.Content.Summary,
				MainImg:   ToPublicImageURL(s.baseImagePath, item.Content.MainImageURL),
				CreatedAt: item.Content.CreatedAt,
			},
		}
	}

	return result, nil
}

func (s *vitrineService) ReplaceConfig(deviceID uint, request DTO.ReplaceVitrineConfigRequest) error {
	if _, err := s.DeviceRepository.GetByIDDevice(deviceID); err != nil {
		return errors.New("دستگاه یافت نشد")
	}

	seenPositions := make(map[int]bool, len(request.Items))
	items := make([]Models.VitrineItem, 0, len(request.Items))

	for _, input := range request.Items {
		if input.Position < 1 || input.Position > request.Size {
			return fmt.Errorf("جایگاه %d خارج از بازه‌ی ویترین (۱ تا %d) است", input.Position, request.Size)
		}
		if seenPositions[input.Position] {
			return fmt.Errorf("جایگاه %d بیش از یک بار تکرار شده است", input.Position)
		}
		seenPositions[input.Position] = true

		content, err := s.ContentRepository.GetByIDContent(input.ContentID)
		if err != nil {
			return fmt.Errorf("محتوای شماره %d یافت نشد", input.ContentID)
		}

		if content.Source != Models.SourceDaralou {
			assigned, err := s.ContentRepository.IsContentAssignedToDevice(deviceID, input.ContentID)
			if err != nil {
				return errors.New("مشکل در چک کردن دسترسی به محتوا: " + err.Error())
			}
			if !assigned {
				return fmt.Errorf("محتوای لوکال شماره %d به این دستگاه اختصاص داده نشده است", input.ContentID)
			}
		}

		items = append(items, Models.VitrineItem{
			DeviceID:  deviceID,
			Position:  input.Position,
			ContentID: input.ContentID,
		})
	}

	tx := s.VitrineRepository.BeginTransaction()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	txVitrineRepo := s.VitrineRepository.WithTransaction(tx)
	txDeviceRepo := s.DeviceRepository.WithTransaction(tx)

	if err := txDeviceRepo.UpdateDevice(deviceID, map[string]interface{}{"vitrine_size": request.Size}); err != nil {
		tx.Rollback()
		return errors.New("خطا در بروزرسانی تعداد اسلات‌های ویترین: " + err.Error())
	}

	if err := txVitrineRepo.ReplaceItems(deviceID, items); err != nil {
		tx.Rollback()
		return errors.New("خطا در ذخیره‌ی چینش ویترین: " + err.Error())
	}

	if err := tx.Commit().Error; err != nil {
		tx.Rollback()
		return errors.New("خطا در تایید تراکنش: " + err.Error())
	}

	return nil
}
