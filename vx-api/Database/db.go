package Database

import (
	"fmt"
	"log"
	"time"

	"vx-api/Config"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

// ইউজার মডেল (টিকটক স্টাইলে আপডেটেড)
type User struct {
	ID           uint       `gorm:"primaryKey"`
	Email        string     `gorm:"type:varchar(100);unique;not null"`
	Provider     string     `gorm:"type:varchar(20);not null"`
	Nickname     string     `gorm:"type:varchar(100)"`       // FullName বদলে Nickname (টিকটক স্টাইল)
	Username     *string    `gorm:"type:varchar(50);unique"` // ইউনিক ইউজারনেম (@username) - Nullable to avoid unique constraint on empty strings
	IsOnboarded  bool       `gorm:"default:false"`           // ফ্লটার অ্যাপ এই ফ্ল্যাগ চেক করবে
	Bio          string     `gorm:"type:text"`               // ইউজার বায়ো
	AvatarURL    string     `gorm:"type:text"`               // প্রোফাইল পিকচার ইউআরএল
	CoverURL     string     `gorm:"type:text"`               // কভার ফটো ইউআরএল
	Following    int        `gorm:"default:0"`               // কতজনকে ফলো করছে
	Followers    int        `gorm:"default:0"`               // কতজন ফলো করছে
	Likes        int        `gorm:"default:0"`               // মোট লাইক সংখ্যা
	RefreshToken string     `gorm:"type:text"`
	OTPCode      string     `gorm:"type:varchar(6)"`
	OTPExpiresAt *time.Time `gorm:"index"`
	Interests    []Category `gorm:"many2many:user_interests;"` // Many-to-Many রিলেশন
	CreatedAt    time.Time
	UpdatedAt    time.Time
	DeletedAt    gorm.DeletedAt `gorm:"index"`
}

// ভিডিও মডেল (টিকটক স্টাইল)
type Video struct {
	ID          uint      `gorm:"primaryKey"`
	UserID      uint      `gorm:"index"`
	User        User      `gorm:"foreignKey:UserID"`
	URL         string    `gorm:"type:text;not null"`
	Caption     string    `gorm:"type:text"`
	Sound       string    `gorm:"type:varchar(100)"`
	Likes       int       `gorm:"default:0"`
	Comments    int       `gorm:"default:0"`
	Shares      int       `gorm:"default:0"`
	IsImage     bool      `gorm:"default:false"`
	Images      []string  `gorm:"type:text[]"` // PostgreSQL array for images
	IsAd        bool      `gorm:"default:false"`
	AdCta       string    `gorm:"type:varchar(50)"`
	AdLink      string    `gorm:"type:text"`
	CreatedAt   time.Time
	UpdatedAt   time.Time
	DeletedAt   gorm.DeletedAt `gorm:"index"`
}

// ক্যাটাগরি মডেল
type Category struct {
	ID        uint   `gorm:"primaryKey"`
	Name      string `gorm:"type:varchar(50);unique;not null"`
	Slug      string `gorm:"type:varchar(50);unique;not null"`
	CreatedAt time.Time
	DeletedAt gorm.DeletedAt `gorm:"index"`
}

func InitDB() {
	dsn := Config.DatabaseDSN
	if dsn == "" {
		log.Fatal("database DSN is empty")
	}

	var err error
	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("DB Connection Error: ", err)
	}

	fmt.Println("PostgreSQL Connected ✅")

	// টেবিল অটো-মাইগ্রেট করবে (নতুন কলাম অটো ডাটাবেজে তৈরি হয়ে যাবে)
	err = DB.AutoMigrate(&User{}, &Category{}, &Video{})
	if err != nil {
		fmt.Println("Migration Warning: ", err)
	}

	// কিছু ডিফল্ট ক্যাটাগরি অটো ইনসার্ট করা (যদি খালি থাকে)
	seedCategories()

	// কিছু ডিফল্ট ইউজার এবং ভিডিও অটো ইনসার্ট করা (যদি খালি থাকে)
	seedVideos()
}

func seedCategories() {
	var count int64
	DB.Model(&Category{}).Count(&count)
	if count == 0 {
		categories := []Category{
			{Name: "Funny & Comedy", Slug: "funny"},
			{Name: "Tech & Gadgets", Slug: "tech"},
			{Name: "Gaming", Slug: "gaming"},
			{Name: "Music & Dance", Slug: "music"},
			{Name: "Sports & Fitness", Slug: "sports"},
			{Name: "Food & Cooking", Slug: "food"},
		}
		DB.Create(&categories)
		fmt.Println("Default Categories Seeded 🌱")
	}
}

func seedVideos() {
	var count int64
	DB.Model(&Video{}).Count(&count)
	if count == 0 {
		// Create Sample Users
		user1Name := "sohan_dev"
		user1 := User{
			Email:       "sohan@example.com",
			Provider:    "email",
			Nickname:    "Sohan Hossain",
			Username:    &user1Name,
			IsOnboarded: true,
			AvatarURL:   "https://api.dicebear.com/7.x/avataaars/svg?seed=Sohan",
		}

		user2Name := "vx_official"
		user2 := User{
			Email:       "support@vx.com",
			Provider:    "email",
			Nickname:    "Vx Official",
			Username:    &user2Name,
			IsOnboarded: true,
			AvatarURL:   "https://api.dicebear.com/7.x/avataaars/svg?seed=VX",
		}

		DB.Create(&user1)
		DB.Create(&user2)

		// Create Sample Videos
		videos := []Video{
			{
				UserID:  user1.ID,
				URL:     "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
				Caption: "Check out this amazing animation! 🐰 #animation #bunny #funny",
				Sound:   "Original Sound - Sohan Hossain",
				Likes:   1200,
				Comments: 45,
				Shares:  89,
			},
			{
				UserID:  user2.ID,
				URL:     "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
				Caption: "The future of video is here on Vx! 🚀 #tech #future #vx",
				Sound:   "Vx Official Theme",
				Likes:   5600,
				Comments: 230,
				Shares:  1200,
			},
			{
				UserID:  user1.ID,
				URL:     "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
				Caption: "Hot blazes! 🔥 #fire #blaze",
				Sound:   "Original Sound - Sohan Hossain",
				Likes:   800,
				Comments: 12,
				Shares:  34,
			},
			{
				UserID:  user2.ID,
				URL:     "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
				Caption: "Time to escape to a new world. 🌍 #travel #escape",
				Sound:   "Travel Vibes",
				Likes:   3400,
				Comments: 98,
				Shares:  450,
			},
		}

		DB.Create(&videos)
		fmt.Println("Default Videos Seeded 🌱")
	}
}
