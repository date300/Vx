package Utils

import (
	"crypto/rand"
	"fmt"
	"math/big"
	"time"

	"vx-api/Config"

	"github.com/golang-jwt/jwt/v5"
)

// সিকিউর ৬ ডিজিটের ওটিপি জেনারেটর
func GenerateOTP() string {
	max := big.NewInt(900000)
	n, _ := rand.Int(rand.Reader, max)
	return fmt.Sprintf("%06d", n.Add(n, big.NewInt(100000)))
}

// প্রোডাকশন-গ্রেড JWT ডুয়াল টোকেন ইঞ্জিন
func GenerateTokens(userID uint) (string, string, error) {
	// ১ ঘণ্টার জন্য অ্যাক্সেস টোকেন
	accessTokenClaims := jwt.MapClaims{
		"user_id": userID,
		"exp":     time.Now().Add(1 * time.Hour).Unix(),
	}
	accessToken := jwt.NewWithClaims(jwt.SigningMethodHS256, accessTokenClaims)
	at, err := accessToken.SignedString([]byte(Config.JWTSecret))
	if err != nil {
		return "", "", err
	}

	// ১ বছরের জন্য রিফ্রেশ টোকেন (লং সেশন)
	refreshTokenClaims := jwt.MapClaims{
		"user_id": userID,
		"exp":     time.Now().Add(365 * 24 * time.Hour).Unix(),
	}
	refreshToken := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshTokenClaims)
	rt, err := refreshToken.SignedString([]byte(Config.JWTSecret))

	return at, rt, err
}
