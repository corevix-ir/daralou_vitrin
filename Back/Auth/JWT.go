package Auth

import (
	"errors"
	"fmt"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid" // v1.6.0  indirect
	"time"
)

type JWTService interface {
	GenerateAccessTokens(userID uint) (*AccessTokenDetails, error)
	GenerateRefreshTokens(userID uint) (*RefreshTokenDetails, error)

	ValidateAccessToken(tokenString string) (*TokenClaims, error)
	ValidateRefreshToken(tokenString string) (*TokenClaims, error)
}

type jwtService struct {
	accessSecret  string
	refreshSecret string
	issuer        string
	accessTTL     time.Duration
	refreshTTL    time.Duration
}

type AccessTokenDetails struct {
	AccessToken string
	AccessUUID  string
	AtExpires   int64
}

type RefreshTokenDetails struct {
	RefreshToken string
	RefreshUUID  string
	RtExpires    int64
}

// مقدارهای خصوصی برای توکن‌ها

type TokenClaims struct {
	UUID   string `json:"uuid"`
	UserID uint   `json:"user_id"`
	jwt.RegisteredClaims
}

// ایجاد سرویس جدید JWT

func NewJWTService(accessSecret, refreshSecret, issuer string, accessTTL, refreshTTL time.Duration) JWTService {
	return &jwtService{
		accessSecret:  accessSecret,
		refreshSecret: refreshSecret,
		issuer:        issuer,
		accessTTL:     accessTTL,
		refreshTTL:    refreshTTL,
	}
}

// GenerateTokens ------------------------------------------------------------------------------------------

func (j *jwtService) GenerateAccessTokens(userID uint) (*AccessTokenDetails, error) {
	td := &AccessTokenDetails{
		AtExpires:  time.Now().Add(j.accessTTL).Unix(), // مدت اعتبار از ACCESS_TOKEN_TTL در .env می‌آید
		AccessUUID: generateUUID(),                     // باید تابع generateUUID() را پیاده‌سازی کنید
	}

	// ساخت توکن دسترسی
	accessClaims := &TokenClaims{
		UUID:   td.AccessUUID,
		UserID: userID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Unix(td.AtExpires, 0)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Issuer:    j.issuer,
		},
	}

	accessToken := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims)
	var err error
	td.AccessToken, err = accessToken.SignedString([]byte(j.accessSecret))
	if err != nil {
		return nil, err
	}

	return td, nil
}

func (j *jwtService) GenerateRefreshTokens(userID uint) (*RefreshTokenDetails, error) {
	td := &RefreshTokenDetails{
		RtExpires:   time.Now().Add(j.refreshTTL).Unix(), // مدت اعتبار از REFRESH_TOKEN_TTL در .env می‌آید
		RefreshUUID: generateUUID(),
	}

	// ساخت توکن تازه‌سازی
	refreshClaims := &TokenClaims{
		UUID:   td.RefreshUUID,
		UserID: userID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Unix(td.RtExpires, 0)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Issuer:    j.issuer,
		},
	}

	refreshToken := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims)

	var err error
	td.RefreshToken, err = refreshToken.SignedString([]byte(j.refreshSecret))
	if err != nil {
		return nil, err
	}

	return td, nil
}

// MethodValidateTokens --------------------------------------------------------------------------------------

func (j *jwtService) ValidateAccessToken(tokenString string) (*TokenClaims, error) {
	return j.validateToken(tokenString, j.accessSecret)
}

func (j *jwtService) ValidateRefreshToken(tokenString string) (*TokenClaims, error) {
	return j.validateToken(tokenString, j.refreshSecret)
}

// CoreValidateToken -------------------------------------------------------------------------------------------

func (j *jwtService) validateToken(tokenString string, secret string) (*TokenClaims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &TokenClaims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		//fmt.Println([]byte(secret))
		return []byte(secret), nil
	})

	if err != nil {
		fmt.Println(err)
		return nil, err
	}

	claims, ok := token.Claims.(*TokenClaims)
	if !ok || !token.Valid {

		return nil, errors.New("invalid token")
	}

	return claims, nil
}

// generateUUID -------------------------------------------------------------------------------------------

func generateUUID() string {
	return uuid.New().String()
}
