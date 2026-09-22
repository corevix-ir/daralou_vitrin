package DTO

import "time"

type CreateContent struct {
	Title     string     `json:"title" validate:"required,min=5,max=50"`
	Body      string     `json:"body" validate:"omitempty,max=2000"`
	Summary   *string    `json:"summary" validate:"omitempty"`
	MainImg   string     `json:"main_img" validate:"required"`
	ImgList   []string   `json:"img_list" validate:"omitempty,max=100"`
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
	Total          int64            `json:"total"`
	Page           int              `json:"page"`
	Size           int              `json:"size"`
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
	StartDate    *time.Time `json:"start_date,omitempty"`
	EndDate      *time.Time `json:"end_date,omitempty"`
	IsPublished  bool       `json:"is_published"`
	CreatedBy    *uint      `json:"created_by"`
	CreatedAt    time.Time
	UpdatedAt    time.Time
}

type UpdateContentRequest struct {
	Title     *string    `json:"title" validate:"omitempty,min=5,max=50"`
	Body      *string    `json:"body" validate:"omitempty,max=2000"`
	Summary   *string    `json:"summary" validate:"omitempty"`
	MainImg   *string    `json:"main_img" validate:"omitempty"`
	ImgList   *[]string  `json:"img_list" validate:"omitempty,max=100"`
	StartDate *time.Time `json:"start_date,omitempty"`
	EndDate   *time.Time `json:"end_date,omitempty"`
}
