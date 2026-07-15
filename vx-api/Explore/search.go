package Explore

import (
"net/http"
"github.com/gin-gonic/gin"
)

func SearchAll(c *gin.Context) {
query := c.Query("q")
c.JSON(http.StatusOK, gin.H{"status": true, "query": query, "message": "সার্চ রেজাল্ট"})
}
