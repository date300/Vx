package Home

import (
"net/http"
"github.com/gin-gonic/gin"
)

func ToggleLike(c *gin.Context) {
videoID := c.Param("id")
c.JSON(http.StatusOK, gin.H{"status": true, "message": "ভিডিও আইডি " + videoID + " তে লাইক সফল!"})
}
