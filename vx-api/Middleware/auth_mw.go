package Middleware

import (
	"fmt"
	"net/http"
	"strings"

	"vx-api/Config"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

func AuthRequired() gin.HandlerFunc {
	return func(c *gin.Context) {
		tokenString := ""
		authorization := strings.TrimSpace(c.GetHeader("Authorization"))

		if strings.HasPrefix(strings.ToLower(authorization), "bearer ") {
			parts := strings.SplitN(authorization, " ", 2)
			if len(parts) == 2 {
				tokenString = strings.TrimSpace(parts[1])
			}
		}

		// Fallback to query parameter (useful for WebSockets)
		if tokenString == "" {
			tokenString = c.Query("token")
		}

		if tokenString == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"status": false, "error": "টোকেন পাওয়া যায়নি! দয়া করে লগইন করুন।"})
			c.Abort()
			return
		}

		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			return []byte(Config.JWTSecret), nil
		})
		if err != nil || !token.Valid {
			fmt.Printf("DEBUG: Auth failed for token: %s, Error: %v\n", tokenString, err)
			c.JSON(http.StatusUnauthorized, gin.H{"status": false, "error": "অবৈধ বা মেয়াদোত্তীর্ণ টোকেন।"})
			c.Abort()
			return
		}

		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{"status": false, "error": "অবৈধ টোকেন ক্লেইম।"})
			c.Abort()
			return
		}

		var userID uint
		switch value := claims["user_id"].(type) {
		case float64:
			userID = uint(value)
		case int:
			userID = uint(value)
		default:
			c.JSON(http.StatusUnauthorized, gin.H{"status": false, "error": "টোকেনে ব্যবহারকারীর পরিচয় পাওয়া যায়নি।"})
			c.Abort()
			return
		}

		c.Set("userID", userID)
		c.Next()
	}
}

// OptionalAuth: টোকেন থাকলে userID সেট করবে, না থাকলে অথবা অবৈধ হলে কিছু করবে না (Next() করবে)
func OptionalAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		tokenString := ""
		authorization := strings.TrimSpace(c.GetHeader("Authorization"))

		if strings.HasPrefix(strings.ToLower(authorization), "bearer ") {
			parts := strings.SplitN(authorization, " ", 2)
			if len(parts) == 2 {
				tokenString = strings.TrimSpace(parts[1])
			}
		}

		if tokenString == "" {
			tokenString = c.Query("token")
		}

		if tokenString == "" {
			c.Next()
			return
		}

		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			return []byte(Config.JWTSecret), nil
		})

		if err == nil && token.Valid {
			if claims, ok := token.Claims.(jwt.MapClaims); ok {
				if val, ok := claims["user_id"]; ok {
					switch v := val.(type) {
					case float64:
						c.Set("userID", uint(v))
					case int:
						c.Set("userID", uint(v))
					}
				}
			}
		}

		c.Next()
	}
}
