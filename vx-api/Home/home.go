package Home

import (
	"time"
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"vx-api/Config"
	
	"vx-api/Middleware"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// RegisterRoutes handles all Home related endpoints
func RegisterRoutes(r *gin.RouterGroup) {
	homeGroup := r.Group("/home")
	{
		// Auth optional করা হয়েছে যাতে লগইন করা ইউজার হলে is_liked/is_following দেখানো যায়,
		// না হলে guest হিসেবে দেখা যায়। OptionalAuth middleware userID সেট করে যদি টোকেন থাকে,
		// error না দিয়ে পরের হ্যান্ডলারে চলে যায়।
		homeGroup.GET("/foryou", Middleware.OptionalAuth(), GetForYouVideos)
		homeGroup.GET("/following", Middleware.AuthRequired(), GetFollowingVideos)
		homeGroup.GET("/friends", Middleware.AuthRequired(), GetFriendsVideos)
	}

	interactionGroup := r.Group("/interaction", Middleware.AuthRequired())
	{
		interactionGroup.POST("/like", ToggleLike)
		interactionGroup.POST("/follow", ToggleFollow)
	}

	// Delete route registered separately to avoid any group parameter conflicts
	r.DELETE("/interaction/video/:id", Middleware.AuthRequired(), DeleteVideo)
	// Fallback/Legacy paths to be absolutely sure
	r.DELETE("/video/:id", Middleware.AuthRequired(), DeleteVideo)

	// Comment endpoints
	commentGroup := r.Group("/video")
	{
		commentGroup.GET("/:id/comments", Middleware.OptionalAuth(), GetComments)
		commentGroup.POST("/:id/comment", Middleware.AuthRequired(), PostComment)
		commentGroup.POST("/:id/view", IncrementViews)
		commentGroup.POST("/comment/:id/like", Middleware.AuthRequired(), ToggleCommentLike)
	}
}

// DeleteVideo handles DELETE /api/v1/interaction/video/:id
func DeleteVideo(c *gin.Context) {
	videoID := c.Param("id")
	userIDRaw, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"status": false, "message": "Unauthorized: User ID not found"})
		return
	}
	userID := userIDRaw.(uint)

	var video Video
	if err := Config.DB.First(&video, videoID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": false, "message": "Video not found in database"})
		return
	}

	// Ownership check
	if video.UserID != userID {
		fmt.Printf("DEBUG: Deletion failed. Video Owner: %d, Request User: %d\n", video.UserID, userID)
		c.JSON(http.StatusForbidden, gin.H{"status": false, "message": "You can only delete your own videos"})
		return
	}

	// Delete physical files
	if video.URL != "" && strings.HasPrefix(video.URL, "/uploads") {
		// e.g. /uploads/videos/xyz.mp4 -> public/uploads/videos/xyz.mp4
		filePath := filepath.Join("public", strings.TrimPrefix(video.URL, "/"))
		if err := os.Remove(filePath); err != nil && !os.IsNotExist(err) {
			fmt.Printf("Warning: failed to delete video file %s: %v\n", filePath, err)
		}
	}

	if video.ThumbnailURL != "" && strings.HasPrefix(video.ThumbnailURL, "/uploads") {
		thumbPath := filepath.Join("public", strings.TrimPrefix(video.ThumbnailURL, "/"))
		if err := os.Remove(thumbPath); err != nil && !os.IsNotExist(err) {
			fmt.Printf("Warning: failed to delete thumbnail file %s: %v\n", thumbPath, err)
		}
	}

	// Delete from DB
	if err := Config.DB.Delete(&video).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to delete video from database"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": true, "message": "Video deleted successfully"})
}

// enrichVideos ভিডিওর লিস্টে is_liked, is_following, is_follow_back যোগ করে
// userID শূন্য (0) হলে সবগুলো false থাকবে (guest/not logged in)
func enrichVideos(userID uint, videos []Video) []gin.H {
	result := make([]gin.H, 0, len(videos))
	if len(videos) == 0 {
		return result
	}

	var likedVideoIDs, followingIDs, followBackIDs map[uint]bool
	likedVideoIDs = map[uint]bool{}
	followingIDs = map[uint]bool{}
	followBackIDs = map[uint]bool{}

	if userID != 0 {
		videoIDs := make([]uint, 0, len(videos))
		uploaderIDs := make([]uint, 0, len(videos))
		for _, v := range videos {
			videoIDs = append(videoIDs, v.ID)
			uploaderIDs = append(uploaderIDs, v.UserID)
		}

		// এই ইউজার কোন কোন ভিডিও লাইক করেছে
		var likes []Like
		Config.DB.Where("user_id = ? AND video_id IN ?", userID, videoIDs).Find(&likes)
		for _, l := range likes {
			likedVideoIDs[l.VideoID] = true
		}

		// এই ইউজার কোন কোন uploader-কে ফলো করে
		var following []Follow
		Config.DB.Where("follower_id = ? AND following_id IN ?", userID, uploaderIDs).Find(&following)
		for _, f := range following {
			followingIDs[f.FollowingID] = true
		}

		// কোন কোন uploader এই ইউজারকে ফলো করে (follow-back দেখানোর জন্য)
		var followBack []Follow
		Config.DB.Where("follower_id IN ? AND following_id = ?", uploaderIDs, userID).Find(&followBack)
		for _, f := range followBack {
			followBackIDs[f.FollowerID] = true
		}
	}

	for _, v := range videos {
		result = append(result, gin.H{
			"id":             v.ID,
			"user_id":        v.UserID,
			"user":           v.User,
			"url":            v.URL,
			"caption":        v.Caption,
			"sound":          v.Sound,
			"duration":      v.Duration,
			"thumbnail_url": v.ThumbnailURL,
			"status":         v.Status,
			"likes":          v.Likes,
			"comments":       v.Comments,
			"views":          v.Views,
			"shares":         v.Shares,
			"is_image":       v.IsImage,
			"images":         v.Images,
			"is_ad":          v.IsAd,
			"ad_cta":         v.AdCta,
			"ad_link":        v.AdLink,
			"created_at":     v.CreatedAt,
			"is_liked":       likedVideoIDs[v.ID],
			"is_following":   followingIDs[v.UserID],
			"is_follow_back": followBackIDs[v.UserID],
		})
	}
	return result
}

// GetForYouVideos handles GET /api/v1/home/foryou
func GetForYouVideos(c *gin.Context) {
	var videos []Video

	// Basic pagination
	var page, limit int
	fmt.Sscanf(c.Query("page"), "%d", &page)
	fmt.Sscanf(c.Query("limit"), "%d", &limit)

	if page <= 0 {
		page = 1
	}
	if limit <= 0 || limit > 50 {
		limit = 10
	}
	offset := (page - 1) * limit

	query := Config.DB.Preload("User").Order("created_at desc")

	// Apply pagination
	if err := query.Limit(limit).Offset(offset).Find(&videos).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  false,
			"message": "Failed to load videos",
		})
		return
	}

	// Force bypass any cache
	c.Header("Cache-Control", "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0")
	c.Header("Pragma", "no-cache")
	c.Header("Expires", "0")

	userID := getUserIDOrZero(c)

	c.JSON(http.StatusOK, gin.H{
		"status":  true,
		"message": "For You feed loaded successfully",
		"data":    enrichVideos(userID, videos),
	})
}

// GetFollowingVideos handles GET /api/v1/home/following
func GetFollowingVideos(c *gin.Context) {
	userID, _ := c.Get("userID")
	uid := userID.(uint)

	// Basic pagination
	var page, limit int
	fmt.Sscanf(c.Query("page"), "%d", &page)
	fmt.Sscanf(c.Query("limit"), "%d", &limit)

	if page <= 0 {
		page = 1
	}
	if limit <= 0 || limit > 50 {
		limit = 10
	}
	offset := (page - 1) * limit

	var followingIDs []uint
	Config.DB.Model(&Follow{}).Where("follower_id = ?", uid).Pluck("following_id", &followingIDs)

	var videos []Video
	if len(followingIDs) > 0 {
		if err := Config.DB.Preload("User").
			Where("user_id IN ?", followingIDs).
			Order("created_at desc").
			Limit(limit).
			Offset(offset).
			Find(&videos).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to load following feed"})
			return
		}
	}

	// Force bypass any cache
	c.Header("Cache-Control", "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0")
	c.Header("Pragma", "no-cache")
	c.Header("Expires", "0")

	c.JSON(http.StatusOK, gin.H{
		"status": true,
		"data":   enrichVideos(uid, videos),
	})
}

// GetFriendsVideos handles GET /api/v1/home/friends
func GetFriendsVideos(c *gin.Context) {
	userID, _ := c.Get("userID")
	uid := userID.(uint)

	// Basic pagination
	var page, limit int
	fmt.Sscanf(c.Query("page"), "%d", &page)
	fmt.Sscanf(c.Query("limit"), "%d", &limit)

	if page <= 0 {
		page = 1
	}
	if limit <= 0 || limit > 50 {
		limit = 10
	}
	offset := (page - 1) * limit

	var friendIDs []uint
	queryRaw := `
		SELECT f1.following_id
		FROM follows f1
		INNER JOIN follows f2 ON f1.following_id = f2.follower_id
		WHERE f1.follower_id = ? AND f2.following_id = ?
	`
	Config.DB.Raw(queryRaw, uid, uid).Scan(&friendIDs)

	var videos []Video
	if len(friendIDs) > 0 {
		if err := Config.DB.Preload("User").
			Where("user_id IN ?", friendIDs).
			Order("created_at desc").
			Limit(limit).
			Offset(offset).
			Find(&videos).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to load friends feed"})
			return
		}
	}

	// Force bypass any cache
	c.Header("Cache-Control", "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0")
	c.Header("Pragma", "no-cache")
	c.Header("Expires", "0")

	c.JSON(http.StatusOK, gin.H{
		"status": true,
		"data":   enrichVideos(uid, videos),
	})
}

// ToggleLike handles POST /api/v1/interaction/like
// এবার আসলেই টগল করে: প্রথমবার like যোগ করে + likes কলাম +1,
// দ্বিতীয়বার (আগে থেকে লাইক করা থাকলে) like রিমুভ করে + likes কলাম -1
func ToggleLike(c *gin.Context) {
	var input struct {
		VideoID uint `json:"video_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "Video ID is required"})
		return
	}

	userIDRaw, _ := c.Get("userID")
	userID := userIDRaw.(uint)

	var existing Like
	err := Config.DB.Where("user_id = ? AND video_id = ?", userID, input.VideoID).First(&existing).Error

	isLiked := false
	err2 := Config.DB.Transaction(func(tx *gorm.DB) error {
		if err == nil {
			// আগে থেকে লাইক করা ছিল -> unlike
			if err := tx.Delete(&existing).Error; err != nil {
				return err
			}
			if err := tx.Model(&Video{}).Where("id = ? AND likes > 0", input.VideoID).
				UpdateColumn("likes", gorm.Expr("likes - 1")).Error; err != nil {
				return err
			}
			isLiked = false
		} else {
			// আগে লাইক ছিল না -> like
			newLike := Like{UserID: userID, VideoID: input.VideoID}
			if err := tx.Create(&newLike).Error; err != nil {
				return err
			}
			if err := tx.Model(&Video{}).Where("id = ?", input.VideoID).
				UpdateColumn("likes", gorm.Expr("likes + 1")).Error; err != nil {
				return err
			}
			isLiked = true
		}
		return nil
	})

	if err2 != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to update like"})
		return
	}

	var video Video
	Config.DB.Select("likes").First(&video, input.VideoID)

	c.JSON(http.StatusOK, gin.H{
		"status":    true,
		"is_liked":  isLiked,
		"likes":     video.Likes,
		"video_id":  input.VideoID,
	})
}

// ToggleFollow handles POST /api/v1/interaction/follow
func ToggleFollow(c *gin.Context) {
	var input struct {
		UserID uint `json:"user_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "User ID is required"})
		return
	}

	followerIDRaw, _ := c.Get("userID")
	followerID := followerIDRaw.(uint)

	if followerID == input.UserID {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "নিজেকে ফলো করা যাবে না"})
		return
	}

	var existing Follow
	err := Config.DB.Where("follower_id = ? AND following_id = ?", followerID, input.UserID).First(&existing).Error

	isFollowing := false
	if err == nil {
		Config.DB.Delete(&existing)
		isFollowing = false
	} else {
		Config.DB.Create(&Follow{FollowerID: followerID, FollowingID: input.UserID})
		isFollowing = true
	}

	c.JSON(http.StatusOK, gin.H{
		"status":       true,
		"is_following": isFollowing,
	})
}

// GetComments handles GET /api/v1/video/:id/comments
func GetComments(c *gin.Context) {
	videoID := c.Param("id")
	userID := getUserIDOrZero(c)

	var comments []Comment
	if err := Config.DB.Preload("User").Where("video_id = ?", videoID).Order("created_at desc").Find(&comments).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to load comments"})
		return
	}

	likedCommentIDs := map[uint]bool{}
	if userID != 0 && len(comments) > 0 {
		commentIDs := make([]uint, 0, len(comments))
		for _, cm := range comments {
			commentIDs = append(commentIDs, cm.ID)
		}
		var commentLikes []CommentLike
		Config.DB.Where("user_id = ? AND comment_id IN ?", userID, commentIDs).Find(&commentLikes)
		for _, cl := range commentLikes {
			likedCommentIDs[cl.CommentID] = true
		}
	}

	data := make([]gin.H, 0, len(comments))
	for _, cm := range comments {
		data = append(data, gin.H{
			"id":         cm.ID,
			"video_id":   cm.VideoID,
			"user":       cm.User,
			"text":       cm.Text,
			"created_at": cm.CreatedAt,
			"likes":      cm.Likes,
			"liked":      likedCommentIDs[cm.ID],
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"status":   true,
		"comments": data,
	})
}

// PostComment handles POST /api/v1/video/:id/comment
func PostComment(c *gin.Context) {
	videoIDStr := c.Param("id")
	userID, _ := c.Get("userID")

	var input struct {
		Text string `json:"text" binding:"required"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "Comment text is required"})
		return
	}

	var videoID uint
	if _, err := fmt.Sscanf(videoIDStr, "%d", &videoID); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "Invalid video ID"})
		return
	}

	// ভিডিওটা আসলেই আছে কিনা যাচাই
	var videoExists int64
	Config.DB.Model(&Video{}).Where("id = ?", videoID).Count(&videoExists)
	if videoExists == 0 {
		c.JSON(http.StatusNotFound, gin.H{"status": false, "message": "Video not found"})
		return
	}

	comment := Comment{
		VideoID: videoID,
		UserID:  userID.(uint),
		Text:    input.Text,
	}

	if err := Config.DB.Create(&comment).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to post comment"})
		return
	}

	if err := Config.DB.Model(&Video{}).Where("id = ?", videoID).UpdateColumn("comments", gorm.Expr("comments + 1")).Error; err != nil {
		fmt.Printf("Error incrementing comment count: %v\n", err)
	}

	if err := Config.DB.Preload("User").First(&comment, comment.ID).Error; err != nil {
		fmt.Printf("Error reloading comment: %v\n", err)
	}

	c.JSON(http.StatusCreated, gin.H{
		"status":  true,
		"message": "Comment posted",
		"comment": gin.H{
			"id":         comment.ID,
			"video_id":   comment.VideoID,
			"user":       comment.User,
			"text":       comment.Text,
			"created_at": comment.CreatedAt,
			"likes":      comment.Likes,
			"liked":      false,
		},
	})
}

// ToggleCommentLike handles POST /api/v1/video/comment/:id/like
func ToggleCommentLike(c *gin.Context) {
	commentIDStr := c.Param("id")
	var commentID uint
	if _, err := fmt.Sscanf(commentIDStr, "%d", &commentID); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "Invalid comment ID"})
		return
	}

	userIDRaw, _ := c.Get("userID")
	userID := userIDRaw.(uint)

	var existing CommentLike
	err := Config.DB.Where("user_id = ? AND comment_id = ?", userID, commentID).First(&existing).Error

	liked := false
	err2 := Config.DB.Transaction(func(tx *gorm.DB) error {
		if err == nil {
			if err := tx.Delete(&existing).Error; err != nil {
				return err
			}
			if err := tx.Model(&Comment{}).Where("id = ? AND likes > 0", commentID).
				UpdateColumn("likes", gorm.Expr("likes - 1")).Error; err != nil {
				return err
			}
			liked = false
		} else {
			if err := tx.Create(&CommentLike{UserID: userID, CommentID: commentID}).Error; err != nil {
				return err
			}
			if err := tx.Model(&Comment{}).Where("id = ?", commentID).
				UpdateColumn("likes", gorm.Expr("likes + 1")).Error; err != nil {
				return err
			}
			liked = true
		}
		return nil
	})

	if err2 != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to update comment like"})
		return
	}

	var comment Comment
	Config.DB.Select("likes").First(&comment, commentID)

	c.JSON(http.StatusOK, gin.H{
		"status":     true,
		"liked":      liked,
		"likes":      comment.Likes,
		"comment_id": commentID,
	})
}

// IncrementViews handles POST /api/v1/video/:id/view
func IncrementViews(c *gin.Context) {
	videoID := c.Param("id")
	if err := Config.DB.Model(&Video{}).Where("id = ?", videoID).UpdateColumn("views", gorm.Expr("views + 1")).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to increment view"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": true, "message": "View incremented"})
}

// getUserIDOrZero OptionalAuth middleware থেকে userID বের করে, না থাকলে 0 রিটার্ন করে
func getUserIDOrZero(c *gin.Context) uint {
	if v, exists := c.Get("userID"); exists {
		if uid, ok := v.(uint); ok {
			return uid
		}
	}
	return 0
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

// Category Model
type Category struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	Name      string         `gorm:"type:varchar(50);unique;not null" json:"name"`
	Slug      string         `gorm:"type:varchar(50);unique;not null" json:"slug"`
	CreatedAt time.Time      `json:"created_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
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

// Comment Model
type Comment struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	VideoID   uint           `gorm:"index;not null" json:"video_id"`
	UserID    uint           `gorm:"index;not null" json:"user_id"`
	User      User           `gorm:"foreignKey:UserID" json:"user"`
	Text      string         `gorm:"type:text;not null" json:"text"`
	Likes     int            `gorm:"default:0" json:"likes"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

// Like Model
type Like struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	UserID    uint      `gorm:"not null;uniqueIndex:idx_user_video_like" json:"user_id"`
	VideoID   uint      `gorm:"not null;uniqueIndex:idx_user_video_like" json:"video_id"`
	CreatedAt time.Time `json:"created_at"`
}

// CommentLike Model
type CommentLike struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	UserID    uint      `gorm:"not null;uniqueIndex:idx_user_comment_like" json:"user_id"`
	CommentID uint      `gorm:"not null;uniqueIndex:idx_user_comment_like" json:"comment_id"`
	CreatedAt time.Time `json:"created_at"`
}

type Follow struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	FollowerID  uint      `gorm:"not null;uniqueIndex:idx_follow_pair" json:"follower_id"`
	FollowingID uint      `gorm:"not null;uniqueIndex:idx_follow_pair" json:"following_id"`
	CreatedAt   time.Time `json:"created_at"`
}

func (Follow) TableName() string {
	return "follows"
}
