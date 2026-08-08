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

// CreateContent godoc
// @Summary      ایجاد محتوای دستی
// @Description  ایجاد یک محتوای دستی (announcement) توسط اپراتور/ادمین
// @Tags         Content
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request  body      DTO.CreateContent  true  "اطلاعات محتوا"
// @Success      201      {object}  DTO.MessageResponse
// @Failure      400      {object}  DTO.ErrorResponse
// @Failure      401      {object}  DTO.ErrorResponse
// @Failure      500      {object}  DTO.ErrorResponse
// @Router       /contents [post]
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

// GetVitrinList godoc
// @Summary      لیست ویترین
// @Description  اخبار اسکرپ‌شده اخیر + محتوای اختصاصی با priority=1 برای دستگاه جاری
// @Tags         Content
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  DTO.VitrinContentList
// @Failure      401  {object}  DTO.ErrorResponse
// @Failure      403  {object}  DTO.ErrorResponse
// @Failure      500  {object}  DTO.ErrorResponse
// @Router       /contents/vitrin [get]
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

// GetScrapContentList godoc
// @Summary      لیست اخبار اسکرپ‌شده
// @Description  لیست صفحه‌بندی‌شده اخبار اسکرپ‌شده (فقط اپراتور/ادمین)
// @Tags         Content
// @Produce      json
// @Security     BearerAuth
// @Param        page  query     int  false  "شماره صفحه (پیش‌فرض 1)"
// @Param        size  query     int  false  "تعداد در هر صفحه (پیش‌فرض 20)"
// @Success      200   {object}  DTO.ContentList
// @Failure      401   {object}  DTO.ErrorResponse
// @Failure      500   {object}  DTO.ErrorResponse
// @Router       /contents/scrap [get]
func (ctrl *ContentController) GetScrapContentList(c echo.Context) error {
	page, size := parsePagination(c)

	result, err := ctrl.contentService.GetScrapContentList(page, size)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, result)
}

// GetLocalContentList godoc
// @Summary      لیست محتوای دستگاه
// @Description  لیست صفحه‌بندی‌شده محتوای اختصاص‌داده‌شده به دستگاه جاری
// @Tags         Content
// @Produce      json
// @Security     BearerAuth
// @Param        page  query     int  false  "شماره صفحه (پیش‌فرض 1)"
// @Param        size  query     int  false  "تعداد در هر صفحه (پیش‌فرض 20)"
// @Success      200   {object}  DTO.ContentList
// @Failure      401   {object}  DTO.ErrorResponse
// @Failure      403   {object}  DTO.ErrorResponse
// @Failure      500   {object}  DTO.ErrorResponse
// @Router       /contents/local [get]
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

// GetDetailsContent godoc
// @Summary      جزئیات یک محتوا
// @Description  دریافت جزئیات کامل یک محتوا؛ برای محتوای دستی، دسترسی دستگاه چک می‌شود
// @Tags         Content
// @Produce      json
// @Security     BearerAuth
// @Param        content_id  path      int  true  "شناسه محتوا"
// @Success      200         {object}  DTO.ContentInfo
// @Failure      400         {object}  DTO.ErrorResponse
// @Failure      401         {object}  DTO.ErrorResponse
// @Failure      403         {object}  DTO.ErrorResponse
// @Failure      404         {object}  DTO.ErrorResponse
// @Router       /contents/{content_id} [get]
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

// UpdateContent godoc
// @Summary      به‌روزرسانی محتوا
// @Description  ویرایش یک محتوای دستی (محتوای اسکرپ‌شده قابل ویرایش نیست)
// @Tags         Content
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id       path      int                       true  "شناسه محتوا"
// @Param        request  body      DTO.UpdateContentRequest  true  "فیلدهای قابل تغییر"
// @Success      200      {object}  DTO.MessageResponse
// @Failure      400      {object}  DTO.ErrorResponse
// @Failure      401      {object}  DTO.ErrorResponse
// @Failure      500      {object}  DTO.ErrorResponse
// @Router       /contents/{id} [put]
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

// DeleteContent godoc
// @Summary      حذف محتوا
// @Description  حذف یک محتوای دستی (محتوای اسکرپ‌شده قابل حذف نیست)
// @Tags         Content
// @Produce      json
// @Security     BearerAuth
// @Param        id  path      int  true  "شناسه محتوا"
// @Success      200 {object}  DTO.MessageResponse
// @Failure      400 {object}  DTO.ErrorResponse
// @Failure      401 {object}  DTO.ErrorResponse
// @Failure      500 {object}  DTO.ErrorResponse
// @Router       /contents/{id} [delete]
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
