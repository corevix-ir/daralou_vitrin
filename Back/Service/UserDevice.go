package Services

import "Back/Repositories"

// UserDeviceService لایه‌ی دسترسی «کدوم اپراتور مالک کدوم دستگاه‌هاست» رو
// مدیریت می‌کنه - برای محدود کردن یک اپراتور (مثلاً یک شرکت پیمانکار) فقط
// به کیوسک‌های خودش، نه کل سیستم. نقش admin از این محدودیت مستثناست (همیشه
// جای دیگه، قبل از صدا زدن این سرویس، چک می‌شه).
type UserDeviceService interface {
	GetOwnedDeviceIDs(userID uint) ([]uint, error)
	IsDeviceOwned(userID, deviceID uint) (bool, error)
	IsAllDevicesOwned(userID uint, deviceIDs []uint) (bool, error)
	ReplaceUserDevices(userID uint, deviceIDs []uint) error
}

type userDeviceService struct {
	Repository Repositories.UserDeviceRepository
}

func NewUserDeviceService(repo Repositories.UserDeviceRepository) UserDeviceService {
	return &userDeviceService{Repository: repo}
}

func (s *userDeviceService) GetOwnedDeviceIDs(userID uint) ([]uint, error) {
	return s.Repository.GetDeviceIDsByUser(userID)
}

func (s *userDeviceService) IsDeviceOwned(userID, deviceID uint) (bool, error) {
	return s.Repository.IsDeviceOwnedByUser(userID, deviceID)
}

// IsAllDevicesOwned true است اگر تمام deviceIDs متعلق به این کاربر باشن (لیست
// خالی همیشه true است - یعنی محدودیتی اعمال نمی‌شه).
func (s *userDeviceService) IsAllDevicesOwned(userID uint, deviceIDs []uint) (bool, error) {
	owned, err := s.Repository.GetDeviceIDsByUser(userID)
	if err != nil {
		return false, err
	}

	ownedSet := make(map[uint]bool, len(owned))
	for _, id := range owned {
		ownedSet[id] = true
	}

	for _, id := range deviceIDs {
		if !ownedSet[id] {
			return false, nil
		}
	}
	return true, nil
}

func (s *userDeviceService) ReplaceUserDevices(userID uint, deviceIDs []uint) error {
	return s.Repository.ReplaceUserDevices(userID, deviceIDs)
}
