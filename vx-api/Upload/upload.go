package Upload

import (
	"time"
	"gorm.io/gorm"
	"vx-api/Home"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"

	"vx-api/Config"
	
	"vx-api/Middleware"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// RegisterRoutes handles all Upload related endpoints
func RegisterRoutes(r *gin.RouterGroup) {
	uploadGroup := r.Group("/upload", Middleware.AuthRequired())
	{
		uploadGroup.POST("/video", Upload)
	}
}

// Upload handles POST /api/v1/upload/video
func Upload(c *gin.Context) {
	rawID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	var uid uint
	switch v := rawID.(type) {
	case float64:
		uid = uint(v)
	case int:
		uid = uint(v)
	case int64:
		uid = uint(v)
	case uint:
		uid = v
	case uint64:
		uid = uint(v)
	default:
		c.JSON(http.StatusInternalServerError, gin.H{"error": "invalid user id"})
		return
	}

	c.Request.Body = http.MaxBytesReader(c.Writer, c.Request.Body, 100<<20)
	if err := c.Request.ParseMultipartForm(10 << 20); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "file too large or bad request"})
		return
	}

	file, header, err := c.Request.FormFile("video")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "no video file provided"})
		return
	}
	defer file.Close()

	ext := strings.ToLower(filepath.Ext(header.Filename))
	if ext != ".mp4" && ext != ".mov" && ext != ".avi" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "unsupported video format"})
		return
	}

	caption := c.PostForm("caption")
	soundIDStr := c.PostForm("sound_id")
	hashtagsStr := c.PostForm("hashtags")
	coverTimestamp := c.PostForm("cover_timestamp") // in seconds, e.g. "1.5"

	uploadDir := Config.UploadDir
	if uploadDir == "" {
		uploadDir = "./public/uploads"
	}

	videoUUID := uuid.New().String()
	videoFileName := videoUUID + ext
	videoPath := filepath.Join(uploadDir, "videos", videoFileName)

	if err := os.MkdirAll(filepath.Dir(videoPath), 0755); err != nil {
		log.Printf("mkdir failed: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "server error"})
		return
	}

	dst, err := os.Create(videoPath)
	if err != nil {
		log.Printf("create file failed: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "server error"})
		return
	}
	defer dst.Close()

	if _, err := io.Copy(dst, file); err != nil {
		log.Printf("copy file failed: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "server error"})
		return
	}

	if coverTimestamp == "" {
		coverTimestamp = "00:00:01"
	}
	thumbnailPath := generateThumbnail(videoPath, uploadDir, videoUUID, coverTimestamp)

	var soundID *int64
	if soundIDStr != "" {
		if id, err := strconv.ParseInt(soundIDStr, 10, 64); err == nil {
			soundID = &id
		}
	}

	videoURL := "/uploads/videos/" + videoFileName
	thumbURL := ""
	if thumbnailPath != "" {
		thumbURL = "/uploads/thumbnails/" + filepath.Base(thumbnailPath)
	}

	video := Video{
		UserID:       uid,
		URL:          videoURL,
		Caption:      caption,
		Duration:     0,
		ThumbnailURL: thumbURL,
		Status:       "processing",
	}
	if soundID != nil {
		video.SoundID = soundID
	}

	if err := Config.DB.Create(&video).Error; err != nil {
		log.Printf("db insert error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "server error"})
		return
	}

	if hashtagsStr != "" {
		tags := strings.Split(hashtagsStr, ",")
		for _, tag := range tags {
			tag = strings.TrimSpace(tag)
			if tag == "" {
				continue
			}
			var hashtag Hashtag
			res := Config.DB.Where("name = ?", tag).FirstOrCreate(&hashtag, Hashtag{Name: tag})
			if res.Error != nil {
				log.Printf("hashtag error: %v", res.Error)
				continue
			}
			Config.DB.Create(&VideoHashtag{
				VideoID:   video.ID,
				HashtagID: hashtag.ID,
			})
		}
	}

	c.JSON(http.StatusCreated, gin.H{
		"id":        video.ID,
		"url":       videoURL,
		"thumbnail": thumbURL,
	})
}

func generateThumbnail(videoPath, uploadDir, videoUUID, timestamp string) string {
	thumbDir := filepath.Join(uploadDir, "thumbnails")
	os.MkdirAll(thumbDir, 0755)
	thumbPath := filepath.Join(thumbDir, videoUUID+".jpg")

	cmd := exec.Command("ffmpeg",
		"-i", videoPath,
		"-ss", timestamp,
		"-vframes", "1",
		"-q:v", "2",
		thumbPath,
	)
	if err := cmd.Run(); err != nil {
		log.Printf("ffmpeg thumbnail error: %v", err)
		return ""
	}
	return thumbPath
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
	Interests    []Home.Category     `gorm:"many2many:user_interests;" json:"interests"`
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

// Hashtag Model
type Hashtag struct {
	ID          uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	Name        string    `gorm:"uniqueIndex;not null" json:"name"`
	TotalVideos int       `gorm:"column:total_videos;default:0" json:"total_videos"`
	TotalViews  int64     `gorm:"column:total_views;default:0" json:"total_views"`
	CreatedAt   time.Time `json:"created_at"`
}

type VideoHashtag struct {
	ID        uint `gorm:"primaryKey;autoIncrement" json:"id"`
	VideoID   uint `gorm:"column:video_id;uniqueIndex:idx_video_hashtag" json:"video_id"`
	HashtagID uint `gorm:"column:hashtag_id;uniqueIndex:idx_video_hashtag" json:"hashtag_id"`
}
