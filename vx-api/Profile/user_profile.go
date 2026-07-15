package Profile

import (
	"net/http"
	"vx-api/Database"
	"github.com/gin-gonic/gin"
)

type OnboardRequest struct {
	Nickname    string `json:"nickname" binding:"required"`     // টিকটক স্টাইলে নিকনেম
	Username    string `json:"username" binding:"required"`     // ইউনিক ইউজারনেম
	CategoryIDs []uint `json:"category_ids" binding:"required"` // বাধ্যতামূলক ক্যাটাগরি
}

type UpdateProfileRequest struct {
	Nickname string `json:"nickname"`
	Username string `json:"username"`
	Bio      string `json:"bio"`
}

// ক্যাটাগরি লিস্ট পাওয়ার এপিআই
func GetCategories(c *gin.Context) {
	var categories []Database.Category
	if err := Database.DB.Find(&categories).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to load categories"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": true, "data": categories})
}

// প্রোফাইল ডেটা পাওয়ার এপিআই
func GetProfile(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"status": false, "message": "Unauthorized"})
		return
	}

	var user Database.User
	if err := Database.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": false, "message": "User not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status": true,
		"data": user,
	})
}

// ইউজার অনবোর্ডিং ডেটা সেভ করার এপিআই
func SaveOnboardingData(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"status": false, "message": "Unauthorized"})
		return
	}

	var req OnboardRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "Nickname, Username, and Categories are required!"})
		return
	}

	// ভ্যালিডেশন চেক
	if len(req.Username) < 3 || len(req.Nickname) < 2 {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "Invalid Username (min 3) or Nickname (min 2)"})
		return
	}

	if len(req.CategoryIDs) < 3 {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "Please select at least 3 categories!"})
		return
	}

	// ইউজারনেম ডুপ্লিকেট চেক
	var existingUser Database.User
	Database.DB.Where("username = ? AND id != ?", req.Username, userID).First(&existingUser)
	if existingUser.ID != 0 {
		c.JSON(http.StatusConflict, gin.H{"status": false, "message": "Username already taken! Try another one."})
		return
	}

	var user Database.User
	if err := Database.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": false, "message": "User not found"})
		return
	}

	var categories []Database.Category
	Database.DB.Find(&categories, req.CategoryIDs)

	// টিকটক ফিল্ড ডাটা সেভ
	user.Nickname = req.Nickname
	user.Username = &req.Username
	user.IsOnboarded = true

	Database.DB.Model(&user).Association("Interests").Replace(categories)
	Database.DB.Save(&user)

	c.JSON(http.StatusOK, gin.H{
		"status": true,
		"message": "TikTok style profile setup completed successfully! 🚀",
	})
}

// প্রোফাইল আপডেট করার এপিআই
func UpdateProfile(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"status": false, "message": "Unauthorized"})
		return
	}

	var req UpdateProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "Invalid request payload"})
		return
	}

	var user Database.User
	if err := Database.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": false, "message": "User not found"})
		return
	}

	// ইউজারনেম আপডেট করলে ডুপ্লিকেট চেক
	if req.Username != "" && (user.Username == nil || *user.Username != req.Username) {
		if len(req.Username) < 3 {
			c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "Username must be at least 3 characters!"})
			return
		}
		var existingUser Database.User
		Database.DB.Where("username = ? AND id != ?", req.Username, userID).First(&existingUser)
		if existingUser.ID != 0 {
			c.JSON(http.StatusConflict, gin.H{"status": false, "message": "Username already taken!"})
			return
		}
		user.Username = &req.Username
	}

	if req.Nickname != "" {
		if len(req.Nickname) < 2 {
			c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "Nickname must be at least 2 characters!"})
			return
		}
		user.Nickname = req.Nickname
	}

	if req.Bio != "" {
		user.Bio = req.Bio
	}

	if err := Database.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to update profile"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  true,
		"message": "Profile updated successfully! ✨",
		"data":    user,
	})
}

