package Explore

import (
	"net/http"
	"strings"
	"time"

	"vx-api/Config"
	"vx-api/Middleware"

	"github.com/gin-gonic/gin"
)

// Sound Model
type Sound struct {
	ID           uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	Title        string    `gorm:"type:varchar(200);not null" json:"title"`
	AuthorName   string    `gorm:"type:varchar(100)" json:"author_name"`
	AuthorAvatar string    `gorm:"type:text" json:"author_avatar"`
	AudioURL     string    `gorm:"type:text;not null" json:"audio_url"`
	TotalVideos  int       `gorm:"column:total_videos;default:0" json:"total_videos"`
	CreatedAt    time.Time `json:"created_at"`
}

// GetSoundDetails handles GET /api/v1/explore/sound/:id
func GetSoundDetails(c *gin.Context) {
	soundID := c.Param("id")
	userID := getUserIDOrZero(c)

	var sound Sound
	if err := Config.DB.First(&sound, soundID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": false, "message": "Sound not found"})
		return
	}

	var videos []Video
	// ওই সাউন্ড ব্যবহার করা ভিডিওগুলো লোড করা
	if err := Config.DB.Preload("User").
		Where("sound_id = ?", soundID).
		Order("views desc").
		Limit(30).
		Find(&videos).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to load videos for this sound"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status": true,
		"sound":  sound,
		"videos": enrichVideos(userID, videos),
	})
}

// SearchSounds handles GET /api/v1/explore/sounds/search?q=query
func SearchSounds(c *gin.Context) {
	query := strings.TrimSpace(c.Query("q"))
	if query == "" {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "Search query is required"})
		return
	}

	limit, offset := parsePagination(c)
	searchTerm := "%" + escapeLike(strings.ToLower(query)) + "%"

	var sounds []Sound
	var total int64

	dbQuery := Config.DB.Model(&Sound{}).
		Where("LOWER(title) LIKE ? ESCAPE '\\' OR LOWER(author_name) LIKE ? ESCAPE '\\'", searchTerm, searchTerm)

	dbQuery.Count(&total)

	if err := dbQuery.Limit(limit).Offset(offset).Find(&sounds).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Sound search failed"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status": true,
		"query":  query,
		"total":  total,
		"limit":  limit,
		"offset": offset,
		"data":   sounds,
	})
}

// UpdateSoundRoutes registers sound-related routes
func UpdateSoundRoutes(group *gin.RouterGroup) {
	group.GET("/sound/:id", Middleware.OptionalAuth(), GetSoundDetails)
	group.GET("/sounds/search", Middleware.OptionalAuth(), SearchSounds)
}
