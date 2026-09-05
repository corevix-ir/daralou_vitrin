package DTO

// VitrineSlot یک اسلات از ویترین رندرشده (پاسخ GET /contents/vitrin) است.
type VitrineSlot struct {
	Position int            `json:"position"`
	Source   string         `json:"source"`  // daralouWeb | daralouOperator
	IsAuto   bool           `json:"is_auto"` // true یعنی این اسلات خودکار از آخرین اخبار پر شده
	Content  SummaryContent `json:"content"`
}

type VitrinContentList struct {
	Items []VitrineSlot `json:"items"`
}

// VitrineItemInput یک آیتم پین‌شده در درخواست تنظیم ویترین است.
type VitrineItemInput struct {
	Position  int  `json:"position" validate:"required,min=1"`
	ContentID uint `json:"content_id" validate:"required"`
}

// ReplaceVitrineConfigRequest کل تنظیمات ویترین یک دستگاه را جایگزین می‌کند.
type ReplaceVitrineConfigRequest struct {
	Size  int                `json:"size" validate:"required,min=1,max=20"`
	Items []VitrineItemInput `json:"items" validate:"dive"`
}

type VitrineItemDetail struct {
	Position int            `json:"position"`
	Source   string         `json:"source"`
	Content  SummaryContent `json:"content"`
}

// VitrineConfig برای نمایش در ادیتور پنل ادمین استفاده می‌شود - فقط آیتم‌های
// پین‌شده را برمی‌گرداند (نه اسلات‌های خودکار).
type VitrineConfig struct {
	Size  int                 `json:"size"`
	Items []VitrineItemDetail `json:"items"`
}
