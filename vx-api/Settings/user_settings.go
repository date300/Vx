package Settings

import (
"net/http"
"github.com/gin-gonic/gin"
)

func UpdateSettings(c *gin.Context) {
c.JSON(http.StatusOK, gin.H{"status": true, "message": "সেটিংস আপডেট করা হয়েছে!"})
}
