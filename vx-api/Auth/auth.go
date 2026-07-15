package Auth

import (
	"errors"
	"fmt"
	"net/http"
	"net/smtp"
	"time"

	"vx-api/Config"
	"vx-api/Database"
	"vx-api/Utils"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func isOTPValid(receivedOTP, storedOTP string, isDevelopment bool) bool {
	if isDevelopment && len(receivedOTP) == 6 {
		// Local development: accept any 6-digit OTP for ease of testing.
		return true
	}
	return receivedOTP == storedOTP
}

// আপনার নিজস্ব ডোমেইন থেকে SSL/TLS মেইল পাঠানোর সিকিউর ইঞ্জিন
func sendSecureEmail(targetEmail, otpCode string) error {
	if Config.SMTPDisabled {
		fmt.Printf("SMTP disabled; OTP for %s is %s\n", targetEmail, otpCode)
		return nil
	}

	from := Config.SMTPFrom
	if from == "" {
		from = "support@easysarvice.com"
	}
	password := Config.SMTPPassword
	smtpHost := Config.SMTPHost
	if smtpHost == "" {
		smtpHost = "easysarvice.com"
	}
	smtpPort := Config.SMTPPort
	if smtpPort == "" {
		smtpPort = "587"
	}

	subject := "Subject: VX App Login Verification Code\n"
	mime := "MIME-version: 1.0;\nContent-Type: text/html; charset=\"UTF-8\";\n\n"
	body := fmt.Sprintf(`
                <div style="font-family: Arial, sans-serif; max-width: 400px; margin: auto; padding: 20px; border: 1px solid #eee; border-radius: 10px; background-color: #ffffff;">
                        <h2 style="color: #333; text-align: center;">VX Verification</h2>
                        <p style="color: #555;">Your secure login one-time password (OTP) is:</p>
                        <div style="background: #f4f4f4; padding: 15px; text-align: center; font-size: 26px; font-weight: bold; letter-spacing: 5px; color: #ff0050; border-radius: 6px;">
                                %s
                        </div>
                        <p style="font-size: 12px; color: #777; margin-top: 20px; text-align: center;">This code is valid for 5 minutes. Do not share it with anyone.</p>
                </div>
        `, otpCode)

	msg := []byte(subject + mime + body)
	auth := smtp.PlainAuth("", from, password, smtpHost)
	return smtp.SendMail(smtpHost+":"+smtpPort, auth, from, []string{targetEmail}, msg)
}

// ১. ইমেইল ওটিপি রিকোয়েস্ট এন্ডপয়েন্ট
func RequestEmailOTP(c *gin.Context) {
	var input struct {
		Email string `json:"email" binding:"required,email"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "error": "Invalid email format"})
		return
	}

	otpCode := Utils.GenerateOTP()

	// রিয়েল মেইল সেন্ড করা হচ্ছে
	if err := sendSecureEmail(input.Email, otpCode); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "error": "Email transmission failed"})
		return
	}

	expiresAt := time.Now().Add(5 * time.Minute)
	var user Database.User

	// SQL Injection ব্লক করতে প্যারামিটারাইজড কুয়েরি
	result := Database.DB.Where("email = ? AND provider = ?", input.Email, "email").First(&user)

	if errors.Is(result.Error, gorm.ErrRecordNotFound) {
		username := fmt.Sprintf("user_%d", time.Now().UnixNano())
		user = Database.User{
			Email:        input.Email,
			Provider:     "email",
			OTPCode:      otpCode,
			OTPExpiresAt: &expiresAt,
			Username:     &username,
		}
		Database.DB.Create(&user)
	} else {
		user.OTPCode = otpCode
		user.OTPExpiresAt = &expiresAt
		Database.DB.Save(&user)
	}

	response := gin.H{"status": true, "message": "Secure OTP sent successfully"}
	if Config.SMTPDisabled {
		response["otp_code"] = otpCode
	}

	c.JSON(http.StatusOK, response)
}

// ২. ওটিপি ভেরিফিকেশন এবং টোকেন জেনারেশন (IsOnboarded ফ্ল্যাগসহ আপডেটেড)
func VerifyEmailOTP(c *gin.Context) {
	var input struct {
		Email string `json:"email" binding:"required,email"`
		OTP   string `json:"otp" binding:"required,len=6"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "Invalid payload data"})
		return
	}

	isDevelopment := Config.AppEnv != "production"
	var user Database.User
	result := Database.DB.Where("email = ? AND provider = ?", input.Email, "email").First(&user)

	if errors.Is(result.Error, gorm.ErrRecordNotFound) {
		if isDevelopment {
			fmt.Printf("User not found in development, creating new user for email: %s\n", input.Email)
			username := fmt.Sprintf("user_%d", time.Now().UnixNano())
			// ডেভেলপমেন্ট মোডে ইউজার না থাকলে নতুন ইউজার তৈরি করুন
			user = Database.User{
				Email:       input.Email,
				Provider:    "email",
				IsOnboarded: false,
				Username:    &username,
			}
			if err := Database.DB.Create(&user).Error; err != nil {
				fmt.Printf("Failed to create user: %v\n", err)
				c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to create user in development: " + err.Error()})
				return
			}
		} else {
			c.JSON(http.StatusUnauthorized, gin.H{"status": false, "message": "User session not found"})
			return
		}
	} else if result.Error != nil {
		fmt.Printf("Database error during user lookup: %v\n", result.Error)
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Database error: " + result.Error.Error()})
		return
	}

	// ওটিপি ম্যাচিং ভ্যালিডেশন
	// ডেভেলপমেন্ট মোডে শিথিলতা: যে কোনো ৬ ডিজিটের কোড গ্রহণ করবে
	if isDevelopment {
		if len(input.OTP) != 6 {
			c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "OTP must be 6 digits"})
			return
		}
		// সাকসেস মেসেজ নিশ্চিত করা
		fmt.Printf("Development login bypass for email: %s\n", input.Email)
	} else {
		if user.OTPCode == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"status": false, "message": "Invalid validation code"})
			return
		}

		if !isOTPValid(input.OTP, user.OTPCode, false) {
			c.JSON(http.StatusUnauthorized, gin.H{"status": false, "message": "Invalid validation code"})
			return
		}

		// টাইম এক্সপায়ারি চেক (বাগ প্রোটেকশন)
		if user.OTPExpiresAt != nil && time.Now().After(*user.OTPExpiresAt) {
			c.JSON(http.StatusUnauthorized, gin.H{"status": false, "message": "OTP token has expired"})
			return
		}
	}

	// সিকিউরিটি ফিক্স: ওটিপি একবার ব্যবহার হলে সাথে সাথে ফ্লাশ (Replay Attack বন্ধ)
	user.OTPCode = ""
	user.OTPExpiresAt = nil

	accessToken, refreshToken, err := Utils.GenerateTokens(user.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "error": "Token encryption error"})
		return
	}

	user.RefreshToken = refreshToken
	Database.DB.Save(&user)

	// 🎯 db.go এর IsOnboarded চেক: অনবোর্ডিং বাকি থাকলে সে নতুন ইউজার
	isNewUser := !user.IsOnboarded

	c.JSON(http.StatusOK, gin.H{
		"status":        true,
		"access_token":  accessToken,
		"refresh_token": refreshToken,
		"is_new_user":   isNewUser, // 🚀 ফ্লটার অ্যাপ এই সিগন্যাল পেয়ে ডিসিশন নেবে
		"user":          gin.H{"id": user.ID, "email": user.Email},
	})
}

// ৩. গুগল সোশ্যাল ওথ এন্ডপয়েন্ট (IsOnboarded ফ্ল্যাগসহ আপডেটেড)
func SocialAuth(c *gin.Context) {
	var input struct {
		Provider    string `json:"provider" binding:"required"`
		SocialToken string `json:"social_token" binding:"required"`
		Email       string `json:"email" binding:"required,email"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "error": "Invalid request payload"})
		return
	}

	if input.Provider != "google" {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "error": "Unsupported provider type"})
		return
	}

	var user Database.User
	result := Database.DB.Where("email = ? AND provider = ?", input.Email, "google").First(&user)

	if errors.Is(result.Error, gorm.ErrRecordNotFound) {
		user = Database.User{
			Email:    input.Email,
			Provider: "google",
		}
		Database.DB.Create(&user)
	}

	accessToken, refreshToken, err := Utils.GenerateTokens(user.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "error": "Token generation error"})
		return
	}

	user.RefreshToken = refreshToken
	Database.DB.Save(&user)

	// 🎯 গুগল লগইনের জন্যও অনবোর্ডিং চেক
	isNewUser := !user.IsOnboarded

	c.JSON(http.StatusOK, gin.H{
		"status":        true,
		"access_token":  accessToken,
		"refresh_token": refreshToken,
		"is_new_user":   isNewUser,
		"user":          gin.H{"id": user.ID, "email": user.Email},
	})
}
