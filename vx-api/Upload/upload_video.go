package Upload

import (
"net/http"
"github.com/gin-gonic/gin"
)

func Upload(c *gin.Context) {
c.JSON(http.StatusCreated, gin.H{"status": true, "message": "ভিডিও সফলভাবে আপলোড হয়েছে!"})
}
