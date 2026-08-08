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

type ContentController struct {
	contentService Services.ContentService
	deviceService  Services.DeviceService
}

func NewContentController(contentService Services.ContentService, deviceService Services.DeviceService) *ContentController {
	return &ContentController{
		contentService: contentService,
		deviceService:  deviceService,
	}
}

func (ctrl *ContentController) CreateContent(c echo.Context) error {
	userID, ok := middleware.GetUserID(c)
	if !ok {
		return c.JSON(http.StatusUnauthorized, echo.Map{"error": "کاربر احراز هویت نشده است"})
	}

	var request DTO.CreateContent
	if err := Validation.ValidateRequest(c, &request); err != nil {
		return err
	}

	if err := ctrl.contentService.CreateContent(userID, request); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusCreated, echo.Map{"message": "محتوا با موفقیت ایجاد شد"})
}

func (ctrl *ContentController) GetVitrinList(c echo.Context) error {
	userID, ok := middleware.GetUserID(c)
	if !ok {
		return c.JSON(http.StatusUnauthorized, echo.Map{"error": "کاربر احراز هویت نشده است"})
	}

	device, err := ctrl.deviceService.GetByUserID(userID)
	if err != nil {
		return c.JSON(http.StatusForbidden, echo.Map{"error": "دستگاه متناظر با این کاربر یافت نشد"})
	}

	result, err1 := ctrl.contentService.GetVitrinList(device.ID)
	if err1 != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err1.Error()})
	}

	return c.JSON(http.StatusOK, result)
}

func (ctrl *ContentController) GetScrapContentList(c echo.Context) error {
	page, size := parsePagination(c)

	result, err := ctrl.contentService.GetScrapContentList(page, size)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, result)
}

func (ctrl *ContentController) GetLocalContentList(c echo.Context) error {
	userID, ok := middleware.GetUserID(c)
	if !ok {
		return c.JSON(http.StatusUnauthorized, echo.Map{"error": "کاربر احراز هویت نشده است"})
	}

	device, err := ctrl.deviceService.GetByUserID(userID)
	if err != nil {
		return c.JSON(http.StatusForbidden, echo.Map{"error": "دستگاه متناظر با این کاربر یافت نشد"})
	}

	page, size := parsePagination(c)

	result, err1 := ctrl.contentService.GetLocalContentList(device.ID, page, size)
	if err1 != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err1.Error()})
	}

	return c.JSON(http.StatusOK, result)
}

func (ctrl *ContentController) GetDetailsContent(c echo.Context) error {
	userID, ok := middleware.GetUserID(c)
	if !ok {
		return c.JSON(http.StatusUnauthorized, echo.Map{"error": "کاربر احراز هویت نشده است"})
	}
	device, err := ctrl.deviceService.GetByUserID(userID)
	if err != nil {
		return c.JSON(http.StatusForbidden, echo.Map{"error": "دستگاه متناظر با این کاربر یافت نشد"})
	}

	contentID, err1 := strconv.Atoi(c.Param("content_id"))
	if err1 != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "شناسه نامعتبر است"})
	}

	result, err1 := ctrl.contentService.GetDetailsContent(uint(contentID), device.ID)
	if err1 != nil {
		return c.JSON(http.StatusNotFound, echo.Map{"error": err1.Error()})
	}

	return c.JSON(http.StatusOK, result)
}

func (ctrl *ContentController) UpdateContent(c echo.Context) error {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "شناسه نامعتبر است"})
	}

	var request DTO.UpdateContentRequest
	if err = c.Bind(&request); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "بدنه درخواست نامعتبر است"})
	}
	if err = c.Validate(&request); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": err.Error()})
	}

	if err = ctrl.contentService.UpdateContent(uint(id), request); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, echo.Map{"message": "محتوا با موفقیت به‌روزرسانی شد"})
}

func (ctrl *ContentController) DeleteContent(c echo.Context) error {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "شناسه نامعتبر است"})
	}

	if err := ctrl.contentService.DeleteContent(uint(id)); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, echo.Map{"message": "محتوا با موفقیت حذف شد"})
}

func parsePagination(c echo.Context) (page, size int) {
	var err error
	page, err = strconv.Atoi(c.QueryParam("page"))
	if err != nil || page < 1 {
		page = 1
	}
	size, err = strconv.Atoi(c.QueryParam("size"))
	if err != nil || size < 1 {
		size = 20
	}
	return page, size
}
