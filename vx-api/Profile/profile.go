package Profile

import (
	"errors"
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"vx-api/Config"
	
	"vx-api/Middleware"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

const (
	avatarDir     = "public/uploads/avatars"
	coverDir      = "public/uploads/covers"
	maxUploadSize = 8 << 20 // 8MB
)

// অনুমোদিত ইমেজ এক্সটেনশন — এর বাইরে কিছু আপলোড হবে না
var allowedImageExt = map[string]bool{
	".jpg":  true,
	".jpeg": true,
	".png":  true,
	".webp": true,
}

// RegisterRoutes handles actions related to the user's own profile
func RegisterRoutes(r *gin.RouterGroup) {
	userGroup := r.Group("/user")
	{
		// Public routes (Auth optional)
		userGroup.GET("/profile/:username", Middleware.OptionalAuth(), GetPublicProfile)
		userGroup.GET("/:username/videos", GetUserVideosByUsername)
		userGroup.GET("/:username/followers", GetFollowers)
		userGroup.GET("/:username/following", GetFollowing)

		// Private routes (Auth required)
		authGroup := userGroup.Group("/", Middleware.AuthRequired())
		{
			authGroup.GET("/profile", GetOwnProfile)
			authGroup.PUT("/profile", UpdateOwnProfile)
			authGroup.GET("/categories", GetCategories)
			authGroup.POST("/onboard", SaveOnboardingData)
			authGroup.POST("/profile/avatar", UploadAvatar)
			authGroup.POST("/profile/cover", UploadCover)
			authGroup.GET("/videos", GetMyVideos)
			
			authGroup.POST("/follow/:username", FollowUser)
			authGroup.DELETE("/follow/:username", UnfollowUser)
		}
	}
}

// ========== Own Profile Logic ==========

func GetOwnProfile(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"status": false, "message": "Unauthorized"})
		return
	}

	var user User
	if err := Config.DB.Preload("Interests").First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": false, "message": "User not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status": true,
		"data":   user,
	})
}

// isUsernameTaken চেক করে username অন্য কোনো ইউজার আগে থেকে নিয়েছে কিনা
// excludeUserID = নিজের ID, নিজেরটার সাথে conflict হিসেবে গণনা না করার জন্য
func isUsernameTaken(username string, excludeUserID interface{}) (bool, error) {
	var count int64
	err := Config.DB.Model(&User{}).
		Where("username = ? AND id != ?", username, excludeUserID).
		Count(&count).Error
	return count > 0, err
}

func UpdateOwnProfile(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"status": false, "message": "Unauthorized"})
		return
	}

	var req struct {
		Nickname     string `json:"nickname"`
		Username     string `json:"username"`
		Bio          string `json:"bio"`
		InstagramURL string `json:"instagram_url"`
		YoutubeURL   string `json:"youtube_url"`
		FacebookURL  string `json:"facebook_url"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "Invalid request"})
		return
	}

	var user User
	if err := Config.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": false, "message": "User not found"})
		return
	}

	if req.Username != "" {
		taken, err := isUsernameTaken(req.Username, userID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to validate username"})
			return
		}
		if taken {
			c.JSON(http.StatusConflict, gin.H{"status": false, "message": "এই ইউজারনেম আগে থেকেই নেওয়া হয়েছে"})
			return
		}
		user.Username = &req.Username
	}

	if req.Nickname != "" {
		user.Nickname = req.Nickname
	}
	user.Bio = req.Bio
	user.InstagramURL = req.InstagramURL
	user.YoutubeURL = req.YoutubeURL
	user.FacebookURL = req.FacebookURL

	if err := Config.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to update profile"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": true, "message": "Profile updated", "data": user})
}

func GetCategories(c *gin.Context) {
	var categories []Category
	if err := Config.DB.Find(&categories).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to fetch categories"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": true, "data": categories})
}

func SaveOnboardingData(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"status": false, "message": "Unauthorized"})
		return
	}

	var req struct {
		Nickname  string `json:"nickname"`
		Username  string `json:"username"`
		Interests []uint `json:"interests"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "Invalid request"})
		return
	}

	if req.Username != "" {
		taken, err := isUsernameTaken(req.Username, userID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to validate username"})
			return
		}
		if taken {
			c.JSON(http.StatusConflict, gin.H{"status": false, "message": "এই ইউজারনেম আগে থেকেই নেওয়া হয়েছে"})
			return
		}
	}

	var user User

	// পুরো onboarding প্রসেসটা একটা transaction-এ — মাঝপথে কোনো ধাপ ফেইল করলে
	// পুরোটাই rollback হয়ে যাবে, interests অর্ধেক অবস্থায় সেভ হবে না
	err := Config.DB.Transaction(func(tx *gorm.DB) error {
		if err := tx.First(&user, userID).Error; err != nil {
			return err
		}

		if err := tx.Model(&user).Association("Interests").Clear(); err != nil {
			return err
		}

		if len(req.Interests) > 0 {
			var categories []Category
			if err := tx.Where("id IN ?", req.Interests).Find(&categories).Error; err != nil {
				return err
			}
			if err := tx.Model(&user).Association("Interests").Append(&categories); err != nil {
				return err
			}
		}

		if req.Nickname != "" {
			user.Nickname = req.Nickname
		}
		if req.Username != "" {
			user.Username = &req.Username
		}
		user.IsOnboarded = true

		return tx.Save(&user).Error
	})

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"status": false, "message": "User not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to save onboarding data"})
		return
	}

	// Interests সহ আপডেটেড ইউজার রিটার্ন করা
	Config.DB.Preload("Interests").First(&user, userID)

	c.JSON(http.StatusOK, gin.H{"status": true, "message": "Onboarding saved", "data": user})
}

// ========== Media Upload Logic ==========

// saveUploadedImage ফাইল টাইপ/সাইজ ভ্যালিডেট করে ডিস্কে সেভ করে, পাবলিক URL রিটার্ন করে
func saveUploadedImage(c *gin.Context, dir string, prefix string) (string, error) {
	file, err := c.FormFile("file")
	if err != nil {
		return "", fmt.Errorf("no file provided: %w", err)
	}

	if file.Size > maxUploadSize {
		return "", fmt.Errorf("file too large (max %dMB)", maxUploadSize/(1<<20))
	}

	ext := strings.ToLower(filepath.Ext(file.Filename))
	if !allowedImageExt[ext] {
		return "", fmt.Errorf("unsupported file type: only jpg, jpeg, png, webp allowed")
	}

	// শুধু extension না, ফাইলের আসল content দেখেও যাচাই করা (magic bytes)
	opened, err := file.Open()
	if err != nil {
		return "", fmt.Errorf("failed to read file")
	}
	defer opened.Close()

	buf := make([]byte, 512)
	n, _ := opened.Read(buf)
	contentType := http.DetectContentType(buf[:n])
	if !strings.HasPrefix(contentType, "image/") {
		return "", fmt.Errorf("file content is not a valid image")
	}

	if err := os.MkdirAll(dir, 0755); err != nil {
		return "", err
	}

	filename := fmt.Sprintf("%s_%d%s", prefix, time.Now().UnixNano(), ext)
	fullPath := filepath.Join(dir, filename)

	if err := c.SaveUploadedFile(file, fullPath); err != nil {
		return "", err
	}

	publicURL := fmt.Sprintf("%s/%s", strings.TrimSuffix(Config.BaseURL, "/"), fullPath)
	return publicURL, nil
}

// deleteOldImageFile পুরনো avatar/cover ফাইল ডিস্ক থেকে মুছে দেয়।
// oldURL খালি হলে বা লোকাল ফাইল না হলে (যেমন কোনো ডিফল্ট/এক্সটার্নাল URL) কিছু করে না।
func deleteOldImageFile(oldURL string) {
	if oldURL == "" {
		return
	}
	base := strings.TrimSuffix(Config.BaseURL, "/") + "/"
	if !strings.HasPrefix(oldURL, base) {
		return // এক্সটার্নাল/ডিফল্ট URL, ডিলিট করার দরকার নেই
	}
	relativePath := strings.TrimPrefix(oldURL, base)
	// path traversal protection
	cleanPath := filepath.Clean(relativePath)
	if strings.Contains(cleanPath, "..") {
		return
	}
	if err := os.Remove(cleanPath); err != nil && !os.IsNotExist(err) {
		fmt.Printf("Warning: failed to delete old file %s: %v\n", cleanPath, err)
	}
}

func UploadAvatar(c *gin.Context) {
	userID, _ := c.Get("userID")

	var user User
	if err := Config.DB.Select("avatar_url").First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": false, "message": "User not found"})
		return
	}
	oldAvatarURL := user.AvatarURL

	url, err := saveUploadedImage(c, avatarDir, "avatar")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": err.Error()})
		return
	}

	if err := Config.DB.Model(&User{}).Where("id = ?", userID).Update("avatar_url", url).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to save avatar"})
		return
	}

	deleteOldImageFile(oldAvatarURL)

	c.JSON(http.StatusOK, gin.H{"status": true, "message": "Avatar updated", "data": gin.H{"avatar_url": url}})
}

func UploadCover(c *gin.Context) {
	userID, _ := c.Get("userID")

	var user User
	if err := Config.DB.Select("cover_url").First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": false, "message": "User not found"})
		return
	}
	oldCoverURL := user.CoverURL

	url, err := saveUploadedImage(c, coverDir, "cover")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": err.Error()})
		return
	}

	if err := Config.DB.Model(&User{}).Where("id = ?", userID).Update("cover_url", url).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to save cover"})
		return
	}

	deleteOldImageFile(oldCoverURL)

	c.JSON(http.StatusOK, gin.H{"status": true, "message": "Cover updated", "data": gin.H{"cover_url": url}})
}

func GetMyVideos(c *gin.Context) {
	userID, _ := c.Get("userID")

	var videos []Video
	if err := Config.DB.Preload("User").Where("user_id = ?", userID).Order("created_at desc").Find(&videos).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to load videos"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": true, "data": videos})
}

// User Model
type User struct {
	ID           uint           `gorm:"primaryKey" json:"id"`
	Email        string         `gorm:"type:varchar(100);unique;not null" json:"email"`
	Provider     string         `gorm:"type:varchar(20);not null" json:"provider"`
	Nickname     string         `gorm:"type:varchar(100)" json:"nickname"`
	Username     *string        `gorm:"type:varchar(50);unique" json:"username"`
	IsOnboarded  bool           `gorm:"default:false" json:"is_onboarded"`
	Bio          string         `gorm:"type:text" json:"bio"`
	AvatarURL    string         `gorm:"type:text" json:"avatar_url"`
	CoverURL     string         `gorm:"type:text" json:"cover_url"`
	Following    int            `gorm:"default:0" json:"following"`
	Followers    int            `gorm:"default:0" json:"followers"`
	Likes        int            `gorm:"default:0" json:"likes"`
	InstagramURL string         `gorm:"type:text" json:"instagram_url"`
	YoutubeURL   string         `gorm:"type:text" json:"youtube_url"`
	FacebookURL  string         `gorm:"type:text" json:"facebook_url"`
	IsVerified   bool           `gorm:"default:false" json:"is_verified"`
	RefreshToken string         `gorm:"type:text" json:"-"`
	OTPCode      string         `gorm:"type:varchar(6)" json:"-"`
	OTPExpiresAt *time.Time     `gorm:"index" json:"-"`
	Interests    []Category     `gorm:"many2many:user_interests;" json:"interests"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`
}

// Video Model
type Video struct {
	ID              uint           `gorm:"primaryKey" json:"id"`
	UserID          uint           `gorm:"index;not null" json:"user_id"`
	User            User           `gorm:"foreignKey:UserID" json:"user"`
	URL             string         `gorm:"type:text;not null" json:"url"`
	Caption         string         `gorm:"type:text" json:"caption"`
	Duration        int            `gorm:"column:duration" json:"duration"`
	ThumbnailURL    string         `gorm:"column:thumbnail_url" json:"thumbnail_url"`
	Status          string         `gorm:"column:status;default:'processing'" json:"status"`
	Views           int64          `gorm:"default:0" json:"views"`
	SoundID         *int64         `gorm:"column:sound_id;default:null" json:"sound_id"`
	Sound           string         `gorm:"type:varchar(100)" json:"sound"`
	OriginalVideoID *uint          `gorm:"index" json:"original_video_id"`
	Likes           int            `gorm:"default:0" json:"likes"`
	Comments        int            `gorm:"default:0" json:"comments"`
	Shares          int            `gorm:"default:0" json:"shares"`
	IsImage         bool           `gorm:"default:false" json:"is_image"`
	Images          []string       `gorm:"type:text[]" json:"images"`
	IsAd            bool           `gorm:"default:false" json:"is_ad"`
	AdCta           string         `gorm:"type:varchar(50)" json:"ad_cta"`
	AdLink          string         `gorm:"type:text" json:"ad_link"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"-"`
}

// Category Model
type Category struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	Name      string         `gorm:"type:varchar(50);unique;not null" json:"name"`
	Slug      string         `gorm:"type:varchar(50);unique;not null" json:"slug"`
	CreatedAt time.Time      `json:"created_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

// ========== Consolidated Public Profile Logic ==========

func GetFollowers(c *gin.Context) {
	username := c.Param("username")
	var user User
	if err := Config.DB.Where("username = ?", username).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": false, "message": "User not found"})
		return
	}

	var followers []User
	Config.DB.Table("users").
		Joins("join follows on follows.follower_id = users.id").
		Where("follows.following_id = ?", user.ID).
		Select("users.*").
		Find(&followers)

	c.JSON(http.StatusOK, gin.H{"status": true, "data": followers})
}

func GetFollowing(c *gin.Context) {
	username := c.Param("username")
	var user User
	if err := Config.DB.Where("username = ?", username).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": false, "message": "User not found"})
		return
	}

	var following []User
	Config.DB.Table("users").
		Joins("join follows on follows.following_id = users.id").
		Where("follows.follower_id = ?", user.ID).
		Select("users.*").
		Find(&following)

	c.JSON(http.StatusOK, gin.H{"status": true, "data": following})
}

func GetPublicProfile(c *gin.Context) {
	myID, _ := c.Get("userID")
	username := c.Param("username")

	var target User
	if err := Config.DB.Where("username = ?", username).First(&target).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": false, "message": "User not found"})
		return
	}

	myIDUint, _ := myID.(uint)
	isSelf := target.ID == myIDUint

	var isFollowing, isFollowedBy bool
	if !isSelf {
		var f Follow
		isFollowing = Config.DB.Where("follower_id = ? AND following_id = ?", myIDUint, target.ID).First(&f).Error == nil

		var fb Follow
		isFollowedBy = Config.DB.Where("follower_id = ? AND following_id = ?", target.ID, myIDUint).First(&fb).Error == nil
	}

	c.JSON(http.StatusOK, gin.H{
		"status": true,
		"data": gin.H{
			"id":             target.ID,
			"nickname":       target.Nickname,
			"username":       target.Username,
			"bio":            target.Bio,
			"avatar_url":     target.AvatarURL,
			"cover_url":      target.CoverURL,
			"following":      target.Following,
			"followers":      target.Followers,
			"likes":          target.Likes,
			"instagram_url":  target.InstagramURL,
			"youtube_url":    target.YoutubeURL,
			"facebook_url":   target.FacebookURL,
			"is_verified":    target.IsVerified,
			"is_following":   isFollowing,
			"is_followed_by": isFollowedBy,
			"is_self":        isSelf,
		},
	})
}

func GetUserVideosByUsername(c *gin.Context) {
	username := c.Param("username")
	var target User
	if err := Config.DB.Where("username = ?", username).First(&target).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": false, "message": "User not found"})
		return
	}

	var videos []Video
	Config.DB.Where("user_id = ?", target.ID).Order("created_at desc").Find(&videos)
	c.JSON(http.StatusOK, gin.H{"status": true, "data": videos})
}

func FollowUser(c *gin.Context) {
	myID, _ := c.Get("userID")
	myIDUint := myID.(uint)
	username := c.Param("username")

	var target User
	if err := Config.DB.Where("username = ?", username).First(&target).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": false, "message": "User not found"})
		return
	}

	if target.ID == myIDUint {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "Cannot follow yourself"})
		return
	}

	// Check if already following to prevent duplicate key errors
	var existing Follow
	if err := Config.DB.Where("follower_id = ? AND following_id = ?", myIDUint, target.ID).First(&existing).Error; err == nil {
		c.JSON(http.StatusOK, gin.H{"status": true, "message": "Already followed"})
		return
	}

	txErr := Config.DB.Transaction(func(tx *gorm.DB) error {
		if err := tx.Create(&Follow{FollowerID: myIDUint, FollowingID: target.ID}).Error; err != nil {
			return err
		}
		tx.Model(&User{}).Where("id = ?", target.ID).UpdateColumn("followers", gorm.Expr("followers + 1"))
		tx.Model(&User{}).Where("id = ?", myIDUint).UpdateColumn("following", gorm.Expr("following + 1"))
		return nil
	})

	if txErr != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to follow"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": true, "message": "Followed"})
}

func UnfollowUser(c *gin.Context) {
	myID, _ := c.Get("userID")
	myIDUint := myID.(uint)
	username := c.Param("username")

	var target User
	if err := Config.DB.Where("username = ?", username).First(&target).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": false, "message": "User not found"})
		return
	}

	txErr := Config.DB.Transaction(func(tx *gorm.DB) error {
		if err := tx.Delete(&Follow{}, "follower_id = ? AND following_id = ?", myIDUint, target.ID).Error; err != nil {
			return err
		}
		tx.Model(&User{}).Where("id = ? AND followers > 0", target.ID).UpdateColumn("followers", gorm.Expr("followers - 1"))
		tx.Model(&User{}).Where("id = ? AND following > 0", myIDUint).UpdateColumn("following", gorm.Expr("following - 1"))
		return nil
	})

	if txErr != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to unfollow"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": true, "message": "Unfollowed"})
}


// Follow Table
type Follow struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	FollowerID  uint      `gorm:"not null;uniqueIndex:idx_follow_pair" json:"follower_id"`
	FollowingID uint      `gorm:"not null;uniqueIndex:idx_follow_pair" json:"following_id"`
	CreatedAt   time.Time `json:"created_at"`
}

func (Follow) TableName() string {
	return "follows"
}
