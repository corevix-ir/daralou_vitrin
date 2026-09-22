package Controllers

import (
	"Back/DTO"
	"Back/Middleware"
	"Back/Models"
	"Back/Service"
	"Back/Validation"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

type AuthController struct {
	authService Services.AuthService
}

func NewAuthController(authService Services.AuthService) *AuthController {
	return &AuthController{authService: authService}
}

// ================================
// 🔓 Public
// ================================

// Login godoc
// @Summary      ورود کاربر
// @Description  احراز هویت با نام کاربری/رمز عبور و دریافت access/refresh token
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        request  body      DTO.LoginRequest  true  "اطلاعات ورود"
// @Success      200      {object}  DTO.TokenResponse
// @Failure      400      {object}  DTO.ErrorResponse
// @Failure      401      {object}  DTO.ErrorResponse
// @Router       /auth/login [post]
func (ctrl *AuthController) Login(c echo.Context) error {
	var request DTO.LoginRequest
	if err := Validation.ValidateRequest(c, &request); err != nil {
		return err
	}

	accessToken, refreshToken, err := ctrl.authService.Login(request.Username, request.Password)
	if err != nil {
		return c.JSON(http.StatusUnauthorized, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"access_token":  accessToken,
		"refresh_token": refreshToken,
	})
}

// RefreshToken godoc
// @Summary      تمدید توکن
// @Description  با ارسال یک refresh token معتبر، access token و refresh token جدید (rotate شده) صادر می‌کند
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        request  body      DTO.RefreshTokenRequest  true  "توکن رفرش فعلی"
// @Success      200      {object}  DTO.TokenResponse
// @Failure      400      {object}  DTO.ErrorResponse
// @Failure      401      {object}  DTO.ErrorResponse
// @Router       /auth/refresh [post]
func (ctrl *AuthController) RefreshToken(c echo.Context) error {
	var request DTO.RefreshTokenRequest
	if err := Validation.ValidateRequest(c, &request); err != nil {
		return err
	}

	accessToken, refreshToken, err := ctrl.authService.RefreshTokens(request.RefreshToken)
	if err != nil {
		return c.JSON(http.StatusUnauthorized, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"access_token":  accessToken,
		"refresh_token": refreshToken,
	})
}

// ================================
// 🔒 Authenticated (خود کاربر)
// ================================

// Logout godoc
// @Summary      خروج کاربر
// @Description  توکن رفرش کاربر جاری را باطل می‌کند
// @Tags         Auth
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  DTO.MessageResponse
// @Failure      401  {object}  DTO.ErrorResponse
// @Failure      500  {object}  DTO.ErrorResponse
// @Router       /auth/logout [post]
func (ctrl *AuthController) Logout(c echo.Context) error {
	userID, ok := middleware.GetUserID(c)
	if !ok {
		return c.JSON(http.StatusUnauthorized, echo.Map{"error": "کاربر احراز هویت نشده است"})
	}

	if err := ctrl.authService.Logout(userID); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, echo.Map{"message": "خروج با موفقیت انجام شد"})
}

// Profile godoc
// @Summary      پروفایل کاربر جاری
// @Description  اطلاعات کاربر احراز هویت‌شده را برمی‌گرداند
// @Tags         Auth
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  DTO.ProfileResponse
// @Failure      401  {object}  DTO.ErrorResponse
// @Failure      404  {object}  DTO.ErrorResponse
// @Router       /auth/profile [get]
func (ctrl *AuthController) Profile(c echo.Context) error {
	userID, ok := middleware.GetUserID(c)
	if !ok {
		return c.JSON(http.StatusUnauthorized, echo.Map{"error": "کاربر احراز هویت نشده است"})
	}

	result, err := ctrl.authService.Profile(userID)
	if err != nil {
		return c.JSON(http.StatusNotFound, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, result)
}

// ================================
// 🛡️ Admin only
// ================================

// Register godoc
// @Summary      ثبت کاربر جدید
// @Description  در حالت عادی فقط ادمین می‌تواند کاربر (operator/user/device) جدید بسازد. استثنا: اگر هنوز هیچ کاربری در سیستم نباشد (اولین راه‌اندازی)، این اندپوینت بدون نیاز به توکن قابل استفاده است و کاربر ساخته‌شده اجباراً admin می‌شود (مقدار role ارسالی نادیده گرفته می‌شود)
// @Tags         Users
// @Accept       json
// @Produce      json
// @Param        request  body      DTO.RegisterRequest  true  "اطلاعات کاربر جدید"
// @Success      201      {object}  DTO.MessageResponse
// @Failure      400      {object}  DTO.ErrorResponse
// @Failure      401      {object}  DTO.ErrorResponse
// @Failure      500      {object}  DTO.ErrorResponse
// @Router       /auth/users [post]
func (ctrl *AuthController) Register(c echo.Context) error {
	var request DTO.RegisterRequest
	if err := Validation.ValidateRequest(c, &request); err != nil {
		return err
	}

	// نگاه کن به middleware.RequireAdminOrBootstrap: وقتی هنوز هیچ کاربری
	// در سیستم نباشه، این فلگ true ست می‌شه و کاربر اول اجباراً admin می‌شه
	// - مستقل از چیزی که کلاینت توی role فرستاده.
	if isBootstrap, _ := c.Get("isBootstrap").(bool); isBootstrap {
		request.Role = Models.RoleAdmin
	}

	if _, err := ctrl.authService.Register(nil, request); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusCreated, echo.Map{"message": "کاربر با موفقیت ایجاد شد"})
}

// UserList godoc
// @Summary      لیست کاربران
// @Description  لیست تمام کاربران سیستم (فقط ادمین)
// @Tags         Users
// @Produce      json
// @Security     BearerAuth
// @Success      200  {array}   DTO.ProfileResponse
// @Failure      401  {object}  DTO.ErrorResponse
// @Failure      500  {object}  DTO.ErrorResponse
// @Router       /auth/users [get]
func (ctrl *AuthController) UserList(c echo.Context) error {
	result, err := ctrl.authService.UserList()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, result)
}

// UpdateUser godoc
// @Summary      به‌روزرسانی کاربر
// @Description  ویرایش اطلاعات یک کاربر (فقط ادمین)
// @Tags         Users
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id       path      int                     true  "شناسه کاربر"
// @Param        request  body      DTO.UpdateUserRequest  true  "فیلدهای قابل تغییر"
// @Success      200      {object}  DTO.MessageResponse
// @Failure      400      {object}  DTO.ErrorResponse
// @Failure      401      {object}  DTO.ErrorResponse
// @Failure      500      {object}  DTO.ErrorResponse
// @Router       /auth/users/{id} [put]
func (ctrl *AuthController) UpdateUser(c echo.Context) error {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "شناسه نامعتبر است"})
	}

	var request DTO.UpdateUserRequest
	if err = Validation.ValidateRequest(c, &request); err != nil {
		return err
	}

	if err = ctrl.authService.UpdateUser(uint(id), request); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, echo.Map{"message": "کاربر با موفقیت به‌روزرسانی شد"})
}

// DeleteUser godoc
// @Summary      حذف کاربر
// @Description  حذف یک کاربر بر اساس شناسه (فقط ادمین)
// @Tags         Users
// @Produce      json
// @Security     BearerAuth
// @Param        id  path      int  true  "شناسه کاربر"
// @Success      200 {object}  DTO.MessageResponse
// @Failure      400 {object}  DTO.ErrorResponse
// @Failure      401 {object}  DTO.ErrorResponse
// @Failure      500 {object}  DTO.ErrorResponse
// @Router       /auth/users/{id} [delete]
func (ctrl *AuthController) DeleteUser(c echo.Context) error {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "شناسه نامعتبر است"})
	}

	if err = ctrl.authService.DeleteUser(uint(id)); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, echo.Map{"message": "کاربر با موفقیت حذف شد"})
}

// GetUserDevices godoc
// @Summary      لیست دستگاه‌های قابل‌دسترسی یک کاربر
// @Description  شناسه‌ی دستگاه‌هایی که این کاربر (اپراتور) بهشون دسترسی داره - فقط ادمین
// @Tags         Users
// @Produce      json
// @Security     BearerAuth
// @Param        id  path      int  true  "شناسه کاربر"
// @Success      200 {object}  DTO.UserDeviceList
// @Failure      400 {object}  DTO.ErrorResponse
// @Failure      401 {object}  DTO.ErrorResponse
// @Failure      500 {object}  DTO.ErrorResponse
// @Router       /auth/users/{id}/devices [get]
func (ctrl *AuthController) GetUserDevices(c echo.Context) error {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "شناسه نامعتبر است"})
	}

	deviceIDs, err := ctrl.authService.GetUserDevices(uint(id))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, DTO.UserDeviceList{DeviceID: deviceIDs})
}

// ReplaceUserDevices godoc
// @Summary      تنظیم دستگاه‌های قابل‌دسترسی یک کاربر
// @Description  جایگزینی کامل لیست دستگاه‌هایی که این کاربر (اپراتور) بهشون دسترسی داره - فقط ادمین. برای محدود کردن یک اپراتور (مثلاً یک شرکت پیمانکار) فقط به کیوسک‌های خودش
// @Tags         Users
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id       path      int                          true  "شناسه کاربر"
// @Param        request  body      DTO.ReplaceUserDevicesRequest  true  "لیست شناسه‌ی دستگاه‌ها"
// @Success      200      {object}  DTO.MessageResponse
// @Failure      400      {object}  DTO.ErrorResponse
// @Failure      401      {object}  DTO.ErrorResponse
// @Failure      500      {object}  DTO.ErrorResponse
// @Router       /auth/users/{id}/devices [put]
func (ctrl *AuthController) ReplaceUserDevices(c echo.Context) error {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "شناسه نامعتبر است"})
	}

	var request DTO.ReplaceUserDevicesRequest
	if err = Validation.ValidateRequest(c, &request); err != nil {
		return err
	}

	if err = ctrl.authService.ReplaceUserDevices(uint(id), request.DeviceID); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, echo.Map{"message": "دستگاه‌های کاربر با موفقیت به‌روزرسانی شد"})
}
