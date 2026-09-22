package Controllers

import (
	"Back/DTO"
	"Back/Service"
	"net/http"

	"github.com/labstack/echo/v4"
)

type UploadController struct {
	uploadService Services.UploadService
}

func NewUploadController(uploadService Services.UploadService) *UploadController {
	return &UploadController{uploadService: uploadService}
}

// UploadImage godoc
// @Summary      آپلود تصویر
// @Description  آپلود یک فایل تصویر (jpg/png/gif/webp، حداکثر ۵ مگابایت) و دریافت URL عمومی قابل‌استفاده در main_img/img_list محتوا
// @Tags         Uploads
// @Accept       multipart/form-data
// @Produce      json
// @Security     BearerAuth
// @Param        image  formData  file  true  "فایل تصویر"
// @Success      201    {object}  DTO.UploadImageResponse
// @Failure      400    {object}  DTO.ErrorResponse
// @Failure      401    {object}  DTO.ErrorResponse
// @Router       /uploads/images [post]
func (ctrl *UploadController) UploadImage(c echo.Context) error {
	fileHeader, err := c.FormFile("image")
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "فایل تصویر ارسال نشده است"})
	}

	url, err := ctrl.uploadService.SaveImage(fileHeader)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusCreated, DTO.UploadImageResponse{URL: url})
}
