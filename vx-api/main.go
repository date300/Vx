package main

import (
	"fmt"
	"vx-api/Auth"
	"vx-api/Config"
	"vx-api/Explore"
	"vx-api/Home"
	"vx-api/Inbox"
	"vx-api/Middleware"
	"vx-api/Profile"
	"vx-api/Realtime"
	"vx-api/Settings"
	"vx-api/Studio"
	"vx-api/Upload"

	"github.com/gin-gonic/gin"
)

func main() {
	Config.InitDB()

	// Ensure essential tables are migrated
	
	// Auto-Migrate all models
	Config.DB.AutoMigrate(
		&Profile.User{},
		&Profile.Category{},
		&Profile.Video{},
		&Home.Comment{},
		&Home.Like{},
		&Home.CommentLike{},
		&Profile.Follow{},
		&Inbox.Notification{},
		&Inbox.Conversation{},
		&Inbox.Message{},
		&Explore.Hashtag{},
		&Explore.Sound{},
		&Explore.VideoHashtag{},
		&Settings.UserSettings{},
		&Studio.DailyStats{},
	)


	if Config.AppEnv == "production" {
		gin.SetMode(gin.ReleaseMode)
	} else {
		gin.SetMode(gin.DebugMode)
	}

	r := gin.Default()

	// Enable CORS
	r.Use(Middleware.CORSMiddleware())

	// Initialize Realtime Hub
	go Realtime.MainHub.Run()

	// Static files for avatars, covers, and videos
	r.Static("/public", "./public")
	r.Static("/uploads", "./public/uploads")
	r.Static("/thumbnails", "./public/uploads/thumbnails")
	r.Static("/images", "./public/uploads/images")

	// Global API Group - Top level /api
	api := r.Group("/api/v1")
	{
		// Module routers
		Auth.RegisterRoutes(api)
		Home.RegisterRoutes(api)
		Profile.RegisterRoutes(api)    // Profile actions (Consolidated)
		Explore.RegisterRoutes(api)    // Explore & Search
		Inbox.RegisterRoutes(api)      // Inbox & Notifications
		Settings.RegisterRoutes(api)   // User Settings
		Studio.RegisterRoutes(api)     // Creator Studio
		Upload.RegisterRoutes(api)
		Realtime.RegisterRoutes(api)

		// Explicit debug route to test if DELETE works at all
		api.DELETE("/test-delete/:id", func(c *gin.Context) {
			c.JSON(200, gin.H{"status": true, "message": "Delete reached", "id": c.Param("id")})
		})
	}

	fmt.Printf("VX API Engine Running on %s:%s...\n", Config.ServerHost, Config.ServerPort)
	if err := r.Run(Config.ServerHost + ":" + Config.ServerPort); err != nil {
		panic(err)
	}
}
