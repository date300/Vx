package Home

import (
	"net/http"
	"vx-api/Database"
	"github.com/gin-gonic/gin"
)

func GetForYouVideos(c *gin.Context) {
	var videos []Database.Video

	// Fetch videos with User details (Preload)
	if err := Database.DB.Preload("User").Order("created_at desc").Find(&videos).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status": false,
			"message": "Failed to load videos",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status": true,
		"message": "For You feed loaded successfully",
		"data": videos,
	})
}
