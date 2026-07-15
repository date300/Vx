package main

import (
	"fmt"

	"vx-api/Auth"
	"vx-api/Config"
	"vx-api/Database"
	"vx-api/Home"
	"vx-api/Middleware"
	"vx-api/Profile"
	"vx-api/Upload"

	"github.com/gin-gonic/gin"
)

func main() {
	Database.InitDB()

	if Config.AppEnv == "production" {
		gin.SetMode(gin.ReleaseMode)
	} else {
		gin.SetMode(gin.DebugMode)
	}

	r := gin.Default()

	api := r.Group("/api/v1")
	{
		// পাবলিক রাউটস
		homeGroup := api.Group("/home")
		{
			homeGroup.GET("/foryou", Home.GetForYouVideos)
		}

		// পাবলিক অথেনটিকেশন রাউটস
		authGroup := api.Group("/auth")
		{
			authGroup.POST("/email-request", Auth.RequestEmailOTP)
			authGroup.POST("/email-verify", Auth.VerifyEmailOTP)
			authGroup.POST("/social", Auth.SocialAuth)
		}

		// সুরক্ষিত রাউটস (টোকেন লাগবে)
		userGroup := api.Group("/user", Middleware.AuthRequired())
		{
			userGroup.GET("/profile", Profile.GetProfile)          // প্রোফাইল দেখতে
			userGroup.PUT("/profile", Profile.UpdateProfile)       // প্রোফাইল আপডেট করতে
			userGroup.GET("/categories", Profile.GetCategories)    // ক্যাটাগরি লিস্ট দেখতে
			userGroup.POST("/onboard", Profile.SaveOnboardingData) // অনবোর্ডিং সাবমিট করতে
		}

		// সুরক্ষিত আপলোড রাউটস
		uploadGroup := api.Group("/upload", Middleware.AuthRequired())
		{
			uploadGroup.POST("/video", Upload.Upload)
		}
	}

	fmt.Printf("VX API Engine Running on %s:%s...\n", Config.ServerHost, Config.ServerPort)
	if err := r.Run(Config.ServerHost + ":" + Config.ServerPort); err != nil {
		panic(err)
	}
}
