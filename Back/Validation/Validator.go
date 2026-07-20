package Validation

import (
	"fmt"
	"github.com/go-playground/validator/v10"
	"github.com/labstack/echo/v4"
	"net/http"
	"reflect"
	"regexp"
	"strings"
)

// CustomValidator is a struct that wraps validator.Validate
type CustomValidator struct {
	Validator *validator.Validate
}

// Errors represents validation error data structure
type Errors struct {
	Errors map[string]string `json:"errors"`
}

// NewValidator creates a new validator instance
func NewValidator() *CustomValidator {
	v := validator.New()

	// Register a function to get tag name from json tags
	v.RegisterTagNameFunc(func(fld reflect.StructField) string {
		name := strings.SplitN(fld.Tag.Get("json"), ",", 2)[0]
		if name == "-" {
			return ""
		}
		return name
	})

	err := v.RegisterValidation("iran_mobile", func(fl validator.FieldLevel) bool {
		phone := fl.Field().String()

		// الگوی شماره موبایل ایرانی با فرمت بین‌المللی
		// قبول می‌کند: +989123456789
		matched, _ := regexp.MatchString(`^\+989[0-9]{9}$`, phone)
		return matched
	})
	if err != nil {
		fmt.Println("Error iran_mobile validator:", err)
		// بجای return nil، validator ساده برمی‌گردونیم
	}

	// Register custom validations here if needed
	// v.RegisterValidation("customtag", customTagFunc)

	return &CustomValidator{Validator: v}
}

// Validate validates the provided struct
func (cv *CustomValidator) Validate(i interface{}) error {
	if cv.Validator == nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Validator not initialized")
	}

	if err1 := cv.Validator.Struct(i); err1 != nil {
		// Convert validator errors to a map for easier handling
		errors := make(map[string]string)

		for _, err := range err1.(validator.ValidationErrors) {
			// Create descriptive error message
			switch err.Tag() {
			case "required":
				errors[err.Field()] = "این فیلد الزامی است"
			case "email":
				errors[err.Field()] = "فرمت ایمیل نامعتبر است"
			case "min":
				errors[err.Field()] = "مقدار وارد شده کمتر از حد مجاز است"
			case "max":
				errors[err.Field()] = "مقدار وارد شده بیشتر از حد مجاز است"
			case "eqfield":
				errors[err.Field()] = "مقدار وارد شده با " + err.Param() + " مطابقت ندارد"
			case "iran_mobile":
				errors[err.Field()] = "شماره موبایل وارد شده معتبر نیست (مثال صحیح: 989394482227+)"
			case "alphanum":
				errors[err.Field()] = "فقط حروف و اعداد مجاز است"
			default:
				errors[err.Field()] = "مقدار وارد شده نامعتبر است"
			}
		}

		return echo.NewHTTPError(http.StatusBadRequest, Errors{Errors: errors})
	}

	return nil
}

// ValidateRequest is a helper function to validate request data
func ValidateRequest(c echo.Context, i interface{}) error {
	// Bind the request data to the struct
	if err := c.Bind(i); err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, "درخواست نامعتبر")
	}

	// Get the validator from echo context
	v := c.Echo().Validator
	if v == nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Validator not configured")
	}

	// Validate the bound struct
	if err := v.Validate(i); err != nil {
		return err
	}

	return nil
}
