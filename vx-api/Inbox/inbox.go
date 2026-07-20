package Inbox

import (
	"vx-api/Home"
	"time"
	"errors"
	"net/http"
	"strconv"

	"vx-api/Config"
	
	"vx-api/Middleware"
	"vx-api/Realtime"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

const defaultMessagePageSize = 50

// RegisterRoutes handles all Inbox and Notification related endpoints
func RegisterRoutes(r *gin.RouterGroup) {
	inboxGroup := r.Group("/inbox", Middleware.AuthRequired())
	{
		inboxGroup.GET("/notifications", GetNotifications) // Fetch all notifications
		inboxGroup.PUT("/notifications/read", MarkAsRead)  // Mark all as read
		inboxGroup.GET("/unread-count", GetUnreadCount)    // Get total unread count

		// Messaging
		inboxGroup.GET("/conversations", GetConversations)
		inboxGroup.GET("/messages/:target_id", GetMessages)
		inboxGroup.POST("/send", SendMessage)
	}
}

// GetNotifications handles GET /api/v1/inbox/notifications
func GetNotifications(c *gin.Context) {
	userID, _ := c.Get("userID")

	var notifications []Notification
	if err := Config.DB.Preload("Actor").
		Where("user_id = ?", userID).
		Order("created_at desc").
		Find(&notifications).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to fetch notifications"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status": true,
		"data":   notifications,
	})
}

// MarkAsRead handles PUT /api/v1/inbox/notifications/read
func MarkAsRead(c *gin.Context) {
	userID, _ := c.Get("userID")

	if err := Config.DB.Model(&Notification{}).
		Where("user_id = ? AND is_read = ?", userID, false).
		Update("is_read", true).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to update notifications"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  true,
		"message": "All notifications marked as read",
	})
}

// GetConversations handles GET /api/v1/inbox/conversations
// প্রতিটা conversation-এ unread count ও "other user" যোগ করে দেয়, যাতে ফ্রন্টএন্ডে
// প্রতিটা কনভারসেশনের জন্য আলাদা করে গণনা করতে না হয়
func GetConversations(c *gin.Context) {
	userIDRaw, _ := c.Get("userID")
	userID := userIDRaw.(uint)

	var conversations []Conversation
	if err := Config.DB.Preload("User1").Preload("User2").
		Where("user1_id = ? OR user2_id = ?", userID, userID).
		Order("updated_at desc").
		Find(&conversations).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to fetch conversations"})
		return
	}

	if len(conversations) == 0 {
		c.JSON(http.StatusOK, gin.H{"status": true, "data": []gin.H{}})
		return
	}

	convIDs := make([]uint, 0, len(conversations))
	for _, conv := range conversations {
		convIDs = append(convIDs, conv.ID)
	}

	// প্রতিটা conversation-এ আমার unread message সংখ্যা এক কোয়েরিতে বের করা
	type unreadRow struct {
		ConversationID uint
		Count          int64
	}
	var unreadRows []unreadRow
	Config.DB.Model(&Message{}).
		Select("conversation_id, count(*) as count").
		Where("conversation_id IN ? AND receiver_id = ? AND is_read = ?", convIDs, userID, false).
		Group("conversation_id").
		Scan(&unreadRows)

	unreadMap := make(map[uint]int64, len(unreadRows))
	for _, row := range unreadRows {
		unreadMap[row.ConversationID] = row.Count
	}

	data := make([]gin.H, 0, len(conversations))
	for _, conv := range conversations {
		otherUser := conv.User2
		if conv.User1ID != userID {
			otherUser = conv.User1
		}
		data = append(data, gin.H{
			"id":            conv.ID,
			"other_user":    otherUser,
			"last_msg":      conv.LastMsg,
			"updated_at":    conv.UpdatedAt,
			"unread_count":  unreadMap[conv.ID],
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"status": true,
		"data":   data,
	})
}

// GetMessages handles GET /api/v1/inbox/messages/:target_id
// মেসেজ লোড করার সাথে সাথে ওই target-এর পাঠানো unread মেসেজগুলো read হিসেবে মার্ক করে দেয়
func GetMessages(c *gin.Context) {
	myIDRaw, _ := c.Get("userID")
	myID := myIDRaw.(uint)

	targetIDStr := c.Param("target_id")
	targetID64, err := strconv.ParseUint(targetIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "Invalid target ID"})
		return
	}
	targetID := uint(targetID64)

	// পেজিনেশন: ?before_id=123 দিয়ে পুরনো মেসেজ লোড করা যাবে (cursor-based)
	limit := defaultMessagePageSize
	if l, err := strconv.Atoi(c.Query("limit")); err == nil && l > 0 && l <= 100 {
		limit = l
	}

	query := Config.DB.Preload("Sender").
		Where("(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)", myID, targetID, targetID, myID)

	if beforeID, err := strconv.Atoi(c.Query("before_id")); err == nil && beforeID > 0 {
		query = query.Where("id < ?", beforeID)
	}

	var messages []Message
	if err := query.Order("created_at desc").Limit(limit).Find(&messages).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to fetch messages"})
		return
	}

	// সময়ানুক্রমে (পুরনো -> নতুন) সাজানোর জন্য রিভার্স
	for i, j := 0, len(messages)-1; i < j; i, j = i+1, j-1 {
		messages[i], messages[j] = messages[j], messages[i]
	}

	// target থেকে পাঠানো unread মেসেজগুলো read মার্ক করা (async effect নেই, sync-ই যথেষ্ট)
	Config.DB.Model(&Message{}).
		Where("sender_id = ? AND receiver_id = ? AND is_read = ?", targetID, myID, false).
		Update("is_read", true)

	c.JSON(http.StatusOK, gin.H{
		"status": true,
		"data":   messages,
	})
}

// SendMessage handles POST /api/v1/inbox/send
func SendMessage(c *gin.Context) {
	myIDRaw, _ := c.Get("userID")
	myIDUint := myIDRaw.(uint)

	var input struct {
		ReceiverID uint   `json:"receiver_id" binding:"required"`
		Text       string `json:"text" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "Invalid input"})
		return
	}

	if input.ReceiverID == myIDUint {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "নিজেকে মেসেজ পাঠানো যাবে না"})
		return
	}

	// receiver আসলেই আছে কিনা যাচাই
	var receiverExists int64
	Config.DB.Model(&User{}).Where("id = ?", input.ReceiverID).Count(&receiverExists)
	if receiverExists == 0 {
		c.JSON(http.StatusNotFound, gin.H{"status": false, "message": "প্রাপক খুঁজে পাওয়া যায়নি"})
		return
	}

	u1, u2 := myIDUint, input.ReceiverID
	if u1 > u2 {
		u1, u2 = u2, u1
	}

	var msg Message
	var conversation Conversation

	// Find-or-create conversation + create message — একটা transaction-এ, যাতে দুইজন
	// একসাথে প্রথম মেসেজ পাঠালে duplicate conversation তৈরি না হয়।
	// এটা পুরোপুরি race-proof করতে হলে (user1_id, user2_id)-এর উপর DB-লেভেল
	// unique constraint লাগবে — সেটা না থাকলে extreme concurrency-তে এখনও ছোট
	// একটা window থাকতে পারে। থাকলে সবচেয়ে ভালো, নিচের কোড দুটোই handle করে।
	err := Config.DB.Transaction(func(tx *gorm.DB) error {
		err := tx.Where("user1_id = ? AND user2_id = ?", u1, u2).First(&conversation).Error
		if err != nil {
			if !errors.Is(err, gorm.ErrRecordNotFound) {
				return err
			}
			conversation = Conversation{User1ID: u1, User2ID: u2}
			if createErr := tx.Create(&conversation).Error; createErr != nil {
				// আরেকটা রিকোয়েস্ট একই সময়ে conversation বানিয়ে ফেলেছে হতে পারে
				// (unique constraint violation) -> আবার fetch করা
				if fetchErr := tx.Where("user1_id = ? AND user2_id = ?", u1, u2).First(&conversation).Error; fetchErr != nil {
					return createErr
				}
			}
		}

		msg = Message{
			ConversationID: conversation.ID,
			SenderID:       myIDUint,
			ReceiverID:     input.ReceiverID,
			Text:           input.Text,
			IsRead:         false,
		}
		if err := tx.Create(&msg).Error; err != nil {
			return err
		}

		return tx.Model(&conversation).Updates(map[string]interface{}{
			"last_msg":   input.Text,
			"updated_at": msg.CreatedAt,
		}).Error
	})

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "Failed to send message"})
		return
	}

	// Broadcast via WebSocket (Realtime)
	Realtime.MainHub.Broadcast(Realtime.BroadcastMessage{
		Type:    "chat_message",
		Payload: msg,
		Target:  input.ReceiverID,
	})

	c.JSON(http.StatusCreated, gin.H{
		"status": true,
		"data":   msg,
	})
}

// GetUnreadCount handles GET /api/v1/inbox/unread-count
// এখন notification আর message দুই ধরনের unread-ই আলাদাভাবে ও একসাথে (total) রিটার্ন করে
func GetUnreadCount(c *gin.Context) {
	userID, _ := c.Get("userID")

	var notifCount int64
	Config.DB.Model(&Notification{}).
		Where("user_id = ? AND is_read = ?", userID, false).
		Count(&notifCount)

	var msgCount int64
	Config.DB.Model(&Message{}).
		Where("receiver_id = ? AND is_read = ?", userID, false).
		Count(&msgCount)

	c.JSON(http.StatusOK, gin.H{
		"status":            true,
		"unread_count":      notifCount + msgCount, // backward-compatible total
		"notifications":     notifCount,
		"messages":          msgCount,
	})
}

// User Model
type User struct {
	ID           uint           `gorm:"primaryKey" json:"id"`
	Email        string         `gorm:"type:varchar(100);unique;not null" json:"email"`
	Provider     string         `gorm:"type:varchar(20);not null" json:"provider"`
	Nickname     string         `gorm:"type:varchar(100)" json:"nickname"`
	Username     *string        `gorm:"type:varchar(50);unique" json:"username"`
	IsOnboarded  bool           `gorm:"default:false" json:"is_onboarded"`
	Bio          string         `gorm:"type:text" json:"bio"`
	AvatarURL    string         `gorm:"type:text" json:"avatar_url"`
	CoverURL     string         `gorm:"type:text" json:"cover_url"`
	Following    int            `gorm:"default:0" json:"following"`
	Followers    int            `gorm:"default:0" json:"followers"`
	Likes        int            `gorm:"default:0" json:"likes"`
	InstagramURL string         `gorm:"type:text" json:"instagram_url"`
	YoutubeURL   string         `gorm:"type:text" json:"youtube_url"`
	FacebookURL  string         `gorm:"type:text" json:"facebook_url"`
	IsVerified   bool           `gorm:"default:false" json:"is_verified"`
	RefreshToken string         `gorm:"type:text" json:"-"`
	OTPCode      string         `gorm:"type:varchar(6)" json:"-"`
	OTPExpiresAt *time.Time     `gorm:"index" json:"-"`
	Interests    []Home.Category     `gorm:"many2many:user_interests;" json:"interests"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`
}

// Notification Model
type Notification struct {
	ID          uint           `gorm:"primaryKey" json:"id"`
	SenderID    *uint          `gorm:"index" json:"sender_id"`
	ReceiverID  uint           `gorm:"index;not null" json:"receiver_id"`
	Type        string         `gorm:"type:varchar(50);not null" json:"type"` // like, comment, follow, system
	ReferenceID *uint          `json:"reference_id"`
	Title       string         `gorm:"type:varchar(255)" json:"title"`
	Body        string         `gorm:"type:text" json:"body"`
	UserID      uint           `gorm:"index;not null" json:"user_id"`
	ActorID     *uint          `gorm:"index" json:"actor_id"`
	Actor       User           `gorm:"foreignKey:ActorID" json:"actor"`
	Message     string         `gorm:"type:text" json:"message"`
	VideoID     *uint          `gorm:"index" json:"video_id"`
	IsRead      bool           `gorm:"default:false" json:"is_read"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`
}

// Conversation Model
type Conversation struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	User1ID   uint           `gorm:"index;not null" json:"user1_id"`
	User1     User           `gorm:"foreignKey:User1ID" json:"user1"`
	User2ID   uint           `gorm:"index;not null" json:"user2_id"`
	User2     User           `gorm:"foreignKey:User2ID" json:"user2"`
	LastMsg   string         `gorm:"type:text" json:"last_msg"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

// Message Model
type Message struct {
	ID             uint      `gorm:"primaryKey" json:"id"`
	ConversationID uint      `gorm:"index;not null" json:"conversation_id"`
	SenderID       uint      `gorm:"index;not null" json:"sender_id"`
	Sender         User      `gorm:"foreignKey:SenderID" json:"sender"`
	ReceiverID     uint      `gorm:"index;not null" json:"receiver_id"`
	Text           string    `gorm:"type:text;not null" json:"text"`
	IsRead         bool      `gorm:"default:false" json:"is_read"`
	CreatedAt      time.Time `json:"created_at"`
}
