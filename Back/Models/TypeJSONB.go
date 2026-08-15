package Models

import (
	"database/sql/driver"
	"encoding/json"
	"fmt"
)

// JSONB برای پشتیبانی از نوع jsonb در PostgreSQL
type JSONB map[string]interface{}

func (j *JSONB) Scan(value interface{}) error {
	if value == nil {
		*j = JSONB{}
		return nil
	}

	bytes, ok := value.([]byte)
	if !ok {
		return fmt.Errorf("failed to scan JSONB: %T", value)
	}

	return json.Unmarshal(bytes, j)
}

func (j JSONB) Value() (driver.Value, error) {
	if j == nil {
		return []byte(`{}`), nil
	}

	return json.Marshal(j)
}
