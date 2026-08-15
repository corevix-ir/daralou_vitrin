package DTO

import (
	"Back/Models"
	"time"
)

type CreateDevice struct {
	User       RegisterRequest `json:"user" validate:"required"`
	Name       string          `json:"name" validate:"required,min=5,max=50"`
	Location   string          `json:"location" validate:"required,min=20,max=200"`
	Section    string          `json:"section" validate:"omitempty"`
	MacAddress string          `json:"mac_address" validate:"required,min=12,max=12"`
	IPAddress  string          `json:"ip_address" validate:"omitempty"`
	Config     Models.JSONB    `json:"config" validate:"omitempty"`
}

type UpdateDevice struct {
	Name       *string       `json:"name" validate:"omitempty,min=5,max=50"`
	Location   *string       `json:"location" validate:"omitempty,min=20,max=200"`
	Section    *string       `json:"section" validate:"omitempty"`
	MacAddress *string       `json:"mac_address" validate:"omitempty,min=12,max=12"`
	Status     *string       `json:"status" validate:"omitempty"`
	IPAddress  *string       `json:"ip_address" validate:"omitempty"`
	Config     *Models.JSONB `json:"config" validate:"omitempty"`
}

type DeviceList struct {
	ID         uint         `json:"id"`
	Name       string       `json:"name"`
	Location   string       `json:"location"`
	Section    string       `json:"section"`
	MacAddress string       `json:"mac_address"`
	IPAddress  string       `json:"ip_address"`
	Status     string       `json:"status"`
	LastSeen   time.Time    `json:"last_seen"`
	Config     Models.JSONB `json:"config"`
	CreatedAt  time.Time    `json:"created_at"`
}
