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

type VitrineController struct {
	vitrineService    Services.VitrineService
	contentService    Services.ContentService
	userDeviceService Services.UserDeviceService
}

func NewVitrineController(vitrineService Services.VitrineService, contentService Services.ContentService, userDeviceService Services.UserDeviceService) *VitrineController {
	return &VitrineController{
		vitrineService:    vitrineService,
		contentService:    contentService,
		userDeviceService: userDeviceService,
	}
}

// authorizeDevice برای operator چک می‌کنه که این device_id متعلق به خودش
// باشه؛ admin از این چک مستثناست.
func (ctrl *VitrineController) authorizeDevice(c echo.Context, deviceID uint) error {
	role, _ := middleware.GetUserRole(c)
	if role != Models.RoleOperator {
		return nil
	}

	userID, ok := middleware.GetUserID(c)
	if !ok {
		return c.JSON(http.StatusUnauthorized, echo.Map{"error": "کاربر احراز هویت نشده است"})
	}

	owned, err := ctrl.userDeviceService.IsDeviceOwned(userID, deviceID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}
	if !owned {
		return c.JSON(http.StatusForbidden, echo.Map{"error": "شما به این دستگاه دسترسی ندارید"})
	}

	return nil
}

// GetVitrineConfig godoc
// @Summary      دریافت تنظیمات ویترین یک دستگاه
// @Description  تعداد اسلات‌ها و آیتم‌های پین‌شده‌ی ویترین این دستگاه (برای ادیتور پنل ادمین)
// @Tags         Vitrine
// @Produce      json
// @Security     BearerAuth
// @Param        device_id  path      int  true  "شناسه دستگاه"
// @Success      200        {object}  DTO.VitrineConfig
// @Failure      400        {object}  DTO.ErrorResponse
// @Failure      401        {object}  DTO.ErrorResponse
// @Failure      404        {object}  DTO.ErrorResponse
// @Router       /devices/{device_id}/vitrine [get]
func (ctrl *VitrineController) GetVitrineConfig(c echo.Context) error {
	deviceID, err := strconv.ParseUint(c.Param("device_id"), 10, 64)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "شناسه دستگاه نامعتبر است"})
	}
	if errResp := ctrl.authorizeDevice(c, uint(deviceID)); errResp != nil {
		return errResp
	}

	result, err := ctrl.vitrineService.GetConfig(uint(deviceID))
	if err != nil {
		return c.JSON(http.StatusNotFound, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, result)
}

// ReplaceVitrineConfig godoc
// @Summary      تنظیم ویترین یک دستگاه
// @Description  جایگزینی کامل تعداد اسلات‌ها و آیتم‌های پین‌شده‌ی ویترین این دستگاه؛ اسلات‌های پین‌نشده خودکار با آخرین اخبار پر می‌شوند
// @Tags         Vitrine
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        device_id  path      int                            true  "شناسه دستگاه"
// @Param        request    body      DTO.ReplaceVitrineConfigRequest  true  "تعداد اسلات‌ها و آیتم‌های پین‌شده"
// @Success      200        {object}  DTO.MessageResponse
// @Failure      400        {object}  DTO.ErrorResponse
// @Failure      401        {object}  DTO.ErrorResponse
// @Failure      404        {object}  DTO.ErrorResponse
// @Router       /devices/{device_id}/vitrine [put]
func (ctrl *VitrineController) ReplaceVitrineConfig(c echo.Context) error {
	deviceID, err := strconv.ParseUint(c.Param("device_id"), 10, 64)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "شناسه دستگاه نامعتبر است"})
	}
	if errResp := ctrl.authorizeDevice(c, uint(deviceID)); errResp != nil {
		return errResp
	}

	var request DTO.ReplaceVitrineConfigRequest
	if err := Validation.ValidateRequest(c, &request); err != nil {
		return err
	}

	if err := ctrl.vitrineService.ReplaceConfig(uint(deviceID), request); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, echo.Map{"message": "تنظیمات ویترین با موفقیت ذخیره شد"})
}

// GetVitrinePreview godoc
// @Summary      پیش‌نمایش ویترین رندرشده‌ی یک دستگاه
// @Description  همون چیزی که خودِ دستگاه از GET /contents/vitrin می‌بینه، برای هر device_id دلخواه (برای پیش‌نمایش در پنل ادمین)
// @Tags         Vitrine
// @Produce      json
// @Security     BearerAuth
// @Param        device_id  path      int  true  "شناسه دستگاه"
// @Success      200        {object}  DTO.VitrinContentList
// @Failure      400        {object}  DTO.ErrorResponse
// @Failure      401        {object}  DTO.ErrorResponse
// @Failure      404        {object}  DTO.ErrorResponse
// @Router       /devices/{device_id}/vitrine/preview [get]
func (ctrl *VitrineController) GetVitrinePreview(c echo.Context) error {
	deviceID, err := strconv.ParseUint(c.Param("device_id"), 10, 64)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "شناسه دستگاه نامعتبر است"})
	}
	if errResp := ctrl.authorizeDevice(c, uint(deviceID)); errResp != nil {
		return errResp
	}

	result, err := ctrl.contentService.GetVitrinList(uint(deviceID))
	if err != nil {
		return c.JSON(http.StatusNotFound, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, result)
}
