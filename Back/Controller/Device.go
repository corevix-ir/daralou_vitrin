package Controllers

import (
	"Back/DTO"
	"Back/Middleware"
	"Back/Models"
	"Back/Realtime"
	"Back/Service"
	"Back/Validation"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

type DeviceController struct {
	deviceService     Services.DeviceService
	userDeviceService Services.UserDeviceService
	hub               *Realtime.Hub
}

func NewDeviceController(deviceService Services.DeviceService, userDeviceService Services.UserDeviceService, hub *Realtime.Hub) *DeviceController {
	return &DeviceController{deviceService: deviceService, userDeviceService: userDeviceService, hub: hub}
}

// CreateDevice godoc
// @Summary      ایجاد دستگاه
// @Description  ساخت یک دستگاه به‌همراه کاربر مربوطه (نقش device) - فقط ادمین
// @Tags         Devices
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request  body      DTO.CreateDevice  true  "اطلاعات دستگاه"
// @Success      201      {object}  DTO.MessageResponse
// @Failure      400      {object}  DTO.ErrorResponse
// @Failure      401      {object}  DTO.ErrorResponse
// @Failure      500      {object}  DTO.ErrorResponse
// @Router       /devices [post]
func (ctrl *DeviceController) CreateDevice(c echo.Context) error {
	var request DTO.CreateDevice
	if err := Validation.ValidateRequest(c, &request); err != nil {
		return err
	}

	if err := ctrl.deviceService.CreateDevice(request); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusCreated, echo.Map{"message": "دستگاه با موفقیت ایجاد شد"})
}

// GetAllDeviceList godoc
// @Summary      لیست دستگاه‌ها
// @Description  لیست دستگاه‌های ثبت‌شده - ادمین همه‌ی دستگاه‌ها را می‌بیند، اپراتور فقط دستگاه‌هایی که به او اختصاص داده شده
// @Tags         Devices
// @Produce      json
// @Security     BearerAuth
// @Success      200  {array}   DTO.DeviceList
// @Failure      401  {object}  DTO.ErrorResponse
// @Failure      500  {object}  DTO.ErrorResponse
// @Router       /devices [get]
func (ctrl *DeviceController) GetAllDeviceList(c echo.Context) error {
	result, err := ctrl.deviceService.GetAllDeviceList()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	if role, _ := middleware.GetUserRole(c); role == Models.RoleOperator {
		userID, ok := middleware.GetUserID(c)
		if !ok {
			return c.JSON(http.StatusUnauthorized, echo.Map{"error": "کاربر احراز هویت نشده است"})
		}
		ownedIDs, err := ctrl.userDeviceService.GetOwnedDeviceIDs(userID)
		if err != nil {
			return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
		}
		ownedSet := make(map[uint]bool, len(ownedIDs))
		for _, id := range ownedIDs {
			ownedSet[id] = true
		}

		filtered := make([]DTO.DeviceList, 0, len(result))
		for _, device := range result {
			if ownedSet[device.ID] {
				filtered = append(filtered, device)
			}
		}
		result = filtered
	}

	return c.JSON(http.StatusOK, result)
}

// UpdateDevice godoc
// @Summary      به‌روزرسانی دستگاه
// @Description  ویرایش اطلاعات یک دستگاه - فقط ادمین
// @Tags         Devices
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id       path      int               true  "شناسه دستگاه"
// @Param        request  body      DTO.UpdateDevice  true  "فیلدهای قابل تغییر"
// @Success      200      {object}  DTO.MessageResponse
// @Failure      400      {object}  DTO.ErrorResponse
// @Failure      401      {object}  DTO.ErrorResponse
// @Failure      500      {object}  DTO.ErrorResponse
// @Router       /devices/{id} [put]
func (ctrl *DeviceController) UpdateDevice(c echo.Context) error {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "شناسه نامعتبر است"})
	}

	var request DTO.UpdateDevice
	if err = Validation.ValidateRequest(c, &request); err != nil {
		return err
	}

	if err = ctrl.deviceService.UpdateDevice(uint(id), request); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, echo.Map{"message": "دستگاه با موفقیت به‌روزرسانی شد"})
}

// DeleteDevice godoc
// @Summary      حذف دستگاه
// @Description  حذف یک دستگاه بر اساس شناسه - فقط ادمین
// @Tags         Devices
// @Produce      json
// @Security     BearerAuth
// @Param        id  path      int  true  "شناسه دستگاه"
// @Success      200 {object}  DTO.MessageResponse
// @Failure      400 {object}  DTO.ErrorResponse
// @Failure      401 {object}  DTO.ErrorResponse
// @Failure      500 {object}  DTO.ErrorResponse
// @Router       /devices/{id} [delete]
func (ctrl *DeviceController) DeleteDevice(c echo.Context) error {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "شناسه نامعتبر است"})
	}

	if err = ctrl.deviceService.DeleteDevice(uint(id)); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, echo.Map{"message": "دستگاه با موفقیت حذف شد"})
}

// SendCommand godoc
// @Summary      ارسال دستور بلادرنگ به دستگاه
// @Description  از طریق اتصال Socket.IO فعلیِ دستگاه یک دستور فوری برایش می‌فرستد (مثلاً باز کردن پنل ادمین بدون رمز) - فقط ادمین
// @Tags         Devices
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id       path      int                    true  "شناسه دستگاه"
// @Param        request  body      DTO.SendDeviceCommand  true  "نوع و داده دستور"
// @Success      200      {object}  DTO.MessageResponse
// @Failure      400      {object}  DTO.ErrorResponse
// @Failure      401      {object}  DTO.ErrorResponse
// @Failure      409      {object}  DTO.ErrorResponse
// @Router       /devices/{id}/commands [post]
func (ctrl *DeviceController) SendCommand(c echo.Context) error {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "شناسه نامعتبر است"})
	}

	var request DTO.SendDeviceCommand
	if err = Validation.ValidateRequest(c, &request); err != nil {
		return err
	}

	if err = ctrl.hub.SendCommand(uint(id), request.Type, request.Payload); err != nil {
		return c.JSON(http.StatusConflict, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, echo.Map{"message": "دستور با موفقیت ارسال شد"})
}
