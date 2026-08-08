package Controllers

import (
	"Back/DTO"
	"Back/Service"
	"Back/Validation"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

type DeviceController struct {
	deviceService Services.DeviceService
}

func NewDeviceController(deviceService Services.DeviceService) *DeviceController {
	return &DeviceController{deviceService: deviceService}
}

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

func (ctrl *DeviceController) GetAllDeviceList(c echo.Context) error {
	result, err := ctrl.deviceService.GetAllDeviceList()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}
	return c.JSON(http.StatusOK, result)
}

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
