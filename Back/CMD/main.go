package main

import (
	"Back/Bootstrap"
)

// @title           Back API
// @version         1.0
// @description     مستندات API پروژه Back (احراز هویت، مدیریت محتوا، مدیریت دستگاه‌ها).

// @BasePath  /

// @securityDefinitions.apikey  BearerAuth
// @in                          header
// @name                        Authorization
// @description                 توکن دسترسی رو به‌صورت "Bearer {access_token}" وارد کن.

func main() {
	e := Bootstrap.InitializeApp()
	e.Start(":5749")
}
