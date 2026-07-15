package Home

import (
"net/http"
"github.com/gin-gonic/gin"
)

func AddComment(c *gin.Context) {
videoID := c.Param("id")
c.JSON(http.StatusCreated, gin.H{"status": true, "message": "ভিডিও আইডি " + videoID + " তে কমেন্ট যুক্ত হয়েছে!"})
}

func GetComments(c *gin.Context) {
videoID := c.Param("id")
c.JSON(http.StatusOK, gin.H{"status": true, "video_id": videoID, "comments": []string{"Nice!", "Good job!"}})
}
