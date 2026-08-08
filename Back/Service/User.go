package Services

import (
	"Back/Auth"
	"Back/DTO"
	"Back/Models"
	"Back/Repositories"
	"errors"
	"gorm.io/gorm"
	"time"
)

// اینترفیس سرویس auth

type AuthService interface {
	Register(tx *gorm.DB, user DTO.RegisterRequest) (uint, error)
	Login(username, password string) (string, string, error)
	Logout(userID uint) error
	Profile(username uint) (*DTO.ProfileResponse, error)
	UpdateUser(id uint, request DTO.UpdateUserRequest) error
	DeleteUser(id uint) error
	RefreshTokens(refreshToken string) (string, string, error)
	UserList() ([]DTO.ProfileResponse, error)
}

// پیاده‌سازی سرویس
type authService struct {
	Repository Repositories.UserRepository
	jwtService Auth.JWTService
}

func NewAuthService(userRepo Repositories.UserRepository, jwtService Auth.JWTService) AuthService {
	return &authService{
		Repository: userRepo,
		jwtService: jwtService,
	}
}

func (s *authService) Register(tx *gorm.DB, user DTO.RegisterRequest) (uint, error) {

	commit := false
	if tx == nil {
		// شروع transaction
		tx = s.Repository.BeginTransaction()
		defer func() {
			if r := recover(); r != nil {
				tx.Rollback()
			}
		}()
		commit = true
	}

	txAuthRepo := s.Repository.WithTransaction(tx)

	// بررسی یوزرنیم تکراری
	existingEmployee, _ := txAuthRepo.GetByUsername(user.Username)
	if existingEmployee != nil {
		tx.Rollback()
		return 0, errors.New("کاربر قبلاً ثبت شده است")
	}

	// هش کردن پسورد
	hashedPassword, err := Auth.HashPassword(user.Password)
	if err != nil {
		tx.Rollback()
		return 0, errors.New("خطا در هش کردن پسورد")
	}

	newUser := &Models.User{
		Username:     user.Username,
		PasswordHash: hashedPassword,
		Role:         user.Role,
		FullName:     user.Name,
		IsActive:     true,
		CreatedAt:    time.Now(),
	}

	err = txAuthRepo.CreateUser(newUser)
	if err != nil {
		tx.Rollback()
		return 0, err
	}

	// اگر درخواست از API بود کامیت میشه
	if commit {
		// Commit نهایی
		if err = tx.Commit().Error; err != nil {
			tx.Rollback()
			return 0, errors.New("خطا در ذخیره نهایی یوزر " + err.Error())
		}
	}

	// ثبت کاربر در دیتابیس
	return newUser.ID, err
}

func (s *authService) Login(username, password string) (string, string, error) {

	// یافتن یوزر
	employee, err := s.Repository.GetByUsername(username)
	if err != nil || !Auth.CheckPasswordHash(password, employee.PasswordHash) {
		return "", "", errors.New("نام کاربری یا رمز عبور اشتباه است")
	}

	if employee.IsActive == false {
		return "", "", errors.New(" دسترسی شما قطع شده! ")
	}

	// تولید توکن JWT
	accessTokenDetails, err1 := s.jwtService.GenerateAccessTokens(employee.ID)
	if err1 != nil {
		return "", "", errors.New("خطا در ایجاد توکن دسترسی")
	}

	refreshTokenDetails, err2 := s.jwtService.GenerateRefreshTokens(employee.ID)
	if err2 != nil {
		return "", "", errors.New("خطا در ایجاد توکن دسترسی")
	}

	// ذخیره توکن رفرش در دیتابیس
	if err = s.Repository.UpdateRefreshToken(employee.ID, refreshTokenDetails.RefreshToken); err != nil {
		return "", "", errors.New("خطا در ذخیره توکن")
	}

	return accessTokenDetails.AccessToken, refreshTokenDetails.RefreshToken, nil

}

func (s *authService) Logout(userID uint) error {
	err := s.Repository.UpdateRefreshToken(userID, "")
	if err != nil {
		return errors.New("خطا در خروج از حساب : " + err.Error())
	}
	return nil
}

func (s *authService) Profile(ID uint) (*DTO.ProfileResponse, error) {

	user, err := s.Repository.GetByIDUser(ID)
	if err != nil {
		return nil, errors.New("کاربر پیدا نشد")
	}

	// فیلتر کردن اطلاعات حساس از مدل اصلی و ایجاد مدل پاسخ
	employeeResponse := &DTO.ProfileResponse{
		ID:       user.ID,
		Username: user.Username,
		Role:     user.Role,
		IsActive: user.IsActive,
		Name:     user.FullName,
	}

	return employeeResponse, nil
}

func (s *authService) UpdateUser(id uint, request DTO.UpdateUserRequest) error {
	// بررسی وجود خدمت
	_, err := s.Repository.GetByIDUser(id)
	if err != nil {
		return errors.New("کاربر یافت نشد")
	}

	updates := map[string]interface{}{}

	if request.Username != nil {
		updates["username"] = *request.Username
	}
	if request.Password != nil {
		// هش کردن پسورد
		hashedPassword, err1 := Auth.HashPassword(*request.Password)
		if err1 != nil {
			return errors.New("خطا در هش کردن پسورد")
		}
		updates["password_hash"] = hashedPassword
	}
	if request.Name != nil {
		updates["full_name"] = *request.Name
	}
	if request.IsActive != nil {
		updates["is_active"] = *request.IsActive
	}
	if request.Role != nil {
		updates["role"] = *request.Role
	}

	if err = s.Repository.UpdateUser(id, updates); err != nil {
		return errors.New("خطا در آپدیت کاربر: " + err.Error())
	}

	return nil
}

func (s *authService) DeleteUser(id uint) error {
	_, err := s.Repository.GetByIDUser(id)
	if err != nil {
		return errors.New("کاربر یافت نشد")
	}
	if err = s.Repository.DeleteUser(id); err != nil {
		return errors.New("مشکل در حذف کاربر : " + err.Error())
	}
	return nil
}

func (s *authService) RefreshTokens(refreshToken string) (string, string, error) {
	// اعتبارسنجی رفرش توکن (امضا و انقضا)
	claims, err := s.jwtService.ValidateRefreshToken(refreshToken)
	if err != nil {
		return "", "", errors.New("رفرش توکن نامعتبر")
	}

	// بررسی وجود کاربر
	user, err := s.Repository.GetByIDUser(claims.UserID)
	if err != nil {
		return "", "", errors.New("کاربر یافت نشد")
	}

	// بررسی مطابقت توکن با توکن ذخیره‌شده در دیتابیس
	if user.RefreshToken == "" || user.RefreshToken != refreshToken {
		return "", "", errors.New("رفرش توکن نامعتبر است")
	}

	// تولید توکن دسترسی جدید
	accessTokenDetails, err := s.jwtService.GenerateAccessTokens(user.ID)
	if err != nil {
		return "", "", errors.New("خطا در ایجاد توکن دسترسی")
	}

	// تولید و ذخیره‌ی توکن رفرش جدید (rotation)
	refreshTokenDetails, err := s.jwtService.GenerateRefreshTokens(user.ID)
	if err != nil {
		return "", "", errors.New("خطا در ایجاد توکن رفرش")
	}

	if err = s.Repository.UpdateRefreshToken(user.ID, refreshTokenDetails.RefreshToken); err != nil {
		return "", "", errors.New("خطا در ذخیره توکن رفرش")
	}

	return accessTokenDetails.AccessToken, refreshTokenDetails.RefreshToken, nil
}

func (s *authService) UserList() ([]DTO.ProfileResponse, error) {
	users, err := s.Repository.GetAllUser()
	if err != nil {
		return nil, errors.New("خطا در دریافت لیست کاربران : " + err.Error())
	}

	employeesInfos := make([]DTO.ProfileResponse, len(users))
	for i, user := range users {
		employeesInfos[i] = DTO.ProfileResponse{
			ID:       user.ID,
			Username: user.Username,
			Role:     user.Role,
			IsActive: user.IsActive,
			Name:     user.FullName,
		}
	}

	return employeesInfos, nil
}
