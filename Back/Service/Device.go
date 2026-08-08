package Services

import (
	"Back/DTO"
	"Back/Models"
	"Back/Repositories"
	"errors"
	"time"
)

type DeviceService interface {
	CreateDevice(request DTO.CreateDevice) error
	GetAllDeviceList() ([]DTO.DeviceList, error)
	GetByUserID(userID uint) (*Models.Device, error)
	UpdateDevice(id uint, request DTO.UpdateDevice) error
	DeleteDevice(id uint) error
}

type deviceService struct {
	Repository  Repositories.DeviceRepository
	authService AuthService
}

func NewDeviceService(deviceRepo Repositories.DeviceRepository, authService AuthService) DeviceService {
	return &deviceService{
		Repository:  deviceRepo,
		authService: authService,
	}
}

func (s *deviceService) CreateDevice(request DTO.CreateDevice) error {
	tx := s.Repository.BeginTransaction()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	txDeviceRepo := s.Repository.WithTransaction(tx)

	request.User.Role = Models.RoleDevice // فارغ از چیزی که کلاینت فرستاده
	userID, err := s.authService.Register(tx, request.User)
	if err != nil {
		return err
	}

	newDevice := &Models.Device{
		UserID:     userID,
		Name:       request.Name,
		Location:   request.Location,
		Section:    request.Section,
		MacAddress: request.MacAddress,
		IPAddress:  request.IPAddress,
		Config:     request.Config,
		Status:     "active",
		CreatedAt:  time.Now(),
	}

	if err = txDeviceRepo.CreateDevice(newDevice); err != nil {
		tx.Rollback()
		return errors.New("خطا در ایجاد دستگاه: " + err.Error())
	}

	if err = tx.Commit().Error; err != nil {
		tx.Rollback()
		return errors.New("خطا در تایید تراکنش: " + err.Error())
	}

	return nil
}

func (s *deviceService) GetAllDeviceList() ([]DTO.DeviceList, error) {
	devices, err := s.Repository.GetAllDevice()
	if err != nil {
		return nil, errors.New("خطا در دریافت لیست دستگاه‌ها: " + err.Error())
	}

	list := make([]DTO.DeviceList, len(devices))
	for i, d := range devices {
		list[i] = DTO.DeviceList{
			ID:         d.ID,
			Name:       d.Name,
			Location:   d.Location,
			Section:    d.Section,
			MacAddress: d.MacAddress,
			IPAddress:  d.IPAddress,
			Status:     d.Status,
			LastSeen:   d.LastSeen,
			Config:     d.Config,
			CreatedAt:  d.CreatedAt,
		}
	}

	return list, nil
}

func (s *deviceService) GetByUserID(userID uint) (*Models.Device, error) {
	return s.Repository.GetByUserID(userID)
}

func (s *deviceService) UpdateDevice(id uint, request DTO.UpdateDevice) error {
	_, err := s.Repository.GetByIDDevice(id)
	if err != nil {
		return errors.New("دستگاه یافت نشد")
	}

	updates := map[string]interface{}{}

	if request.Name != nil {
		updates["name"] = *request.Name
	}
	if request.Location != nil {
		updates["location"] = *request.Location
	}
	if request.Section != nil {
		updates["section"] = *request.Section
	}
	if request.MacAddress != nil {
		updates["mac_address"] = *request.MacAddress
	}
	if request.Status != nil {
		updates["status"] = *request.Status
	}
	if request.IPAddress != nil {
		updates["ip_address"] = *request.IPAddress
	}
	if request.Config != nil {
		updates["config"] = *request.Config
	}

	if len(updates) == 0 {
		return nil
	}

	if err = s.Repository.UpdateDevice(id, updates); err != nil {
		return errors.New("خطا در آپدیت دستگاه: " + err.Error())
	}

	return nil
}

func (s *deviceService) DeleteDevice(id uint) error {
	_, err := s.Repository.GetByIDDevice(id)
	if err != nil {
		return errors.New("دستگاه یافت نشد")
	}
	if err = s.Repository.DeleteDevice(id); err != nil {
		return errors.New("خطا در حذف دستگاه: " + err.Error())
	}
	return nil
}
