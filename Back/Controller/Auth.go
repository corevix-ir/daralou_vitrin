package Controllers

import (
	"Back/DTO"
	"Back/Service"
	"Back/Validation"
	"Back/middleware"
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

func (ctrl *AuthController) RefreshToken(c echo.Context) error {
	var request DTO.RefreshTokenRequest
	if err := Validation.ValidateRequest(c, &request); err != nil {
		return err
	}

	accessToken, err := ctrl.authService.RefreshTokens(request.RefreshToken)
	if err != nil {
		return c.JSON(http.StatusUnauthorized, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, echo.Map{"access_token": accessToken})
}

// ================================
// 🔒 Authenticated (خود کاربر)
// ================================

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

func (ctrl *AuthController) Register(c echo.Context) error {
	var request DTO.RegisterRequest
	if err := Validation.ValidateRequest(c, &request); err != nil {
		return err
	}

	if _, err := ctrl.authService.Register(nil, request); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusCreated, echo.Map{"message": "کاربر با موفقیت ایجاد شد"})
}

func (ctrl *AuthController) UserList(c echo.Context) error {
	result, err := ctrl.authService.UserList()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, result)
}

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
