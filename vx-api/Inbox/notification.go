package Inbox

import (
"net/http"
"github.com/gin-gonic/gin"
)

func GetNotifications(c *gin.Context) {
c.JSON(http.StatusOK, gin.H{"status": true, "message": "নোটিফিকেশন লিস্ট"})
}
