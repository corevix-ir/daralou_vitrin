package DTO

import "time"

type CreateContent struct {
	Title     string     `json:"title" validate:"required,min=5,max=50"`
	Body      string     `json:"body" validate:"required,min=20,max=2000"`
	Summary   *string    `json:"summary" validate:"omitempty"`
	Priority  int        `json:"priority" validate:"required,min=1,max=3"`
	MainImg   string     `json:"main_img" validate:"required"`
	ImgList   []string   `json:"img_list" validate:"required,min=1,max=100"`
	DeviceID  []uint     `json:"device_id" validate:"required"`
	StartDate *time.Time `json:"start_date,omitempty"`
	EndDate   *time.Time `json:"end_date,omitempty"`
}

type SummaryContent struct {
	ID        uint      `json:"id"`
	Title     string    `json:"title"`
	Summary   *string   `json:"summary"`
	MainImg   string    `json:"main_img"`
	CreatedAt time.Time `json:"created_at"`
}
type ContentList struct {
	SummaryContent []SummaryContent `json:"content"`
}

type VitrinContentList struct {
	Scrap []SummaryContent `json:"scrap_content"`
	Local []SummaryContent `json:"local_content"`
}
type ContentInfo struct {
	ID           uint       `json:"id"`
	ContentType  string     `json:"content_type"`
	Title        string     `json:"title"`
	Body         string     `json:"body"`
	Summary      string     `json:"summary"`
	MainImageURL string     `json:"main_img_url"`
	ExtraImgList []string   `json:"extra_img_list"`
	ExternalURL  string     `json:"external_url"`
	Source       string     `json:"source"`
	Priority     int        `json:"priority"`
	StartDate    *time.Time `json:"start_date,omitempty"`
	EndDate      *time.Time `json:"end_date,omitempty"`
	IsPublished  bool       `json:"is_published"`
	CreatedBy    *uint      `json:"created_by"`
	CreatedAt    time.Time
	UpdatedAt    time.Time
}

type UpdateContentRequest struct {
	Title     *string    `json:"title" validate:"required,min=5,max=50"`
	Body      *string    `json:"body" validate:"required,min=20,max=2000"`
	Summary   *string    `json:"summary" validate:"omitempty"`
	Priority  *int       `json:"priority" validate:"required,min=1,max=3"`
	MainImg   *string    `json:"main_img" validate:"required"`
	ImgList   *[]string  `json:"img_list" validate:"required,min=1,max=100"`
	StartDate *time.Time `json:"start_date,omitempty"`
	EndDate   *time.Time `json:"end_date,omitempty"`
}
