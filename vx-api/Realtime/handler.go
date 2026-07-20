package Realtime

import (
	"net/http"
	"vx-api/Middleware"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true // In production, check origin properly
	},
}

func HandleWS(c *gin.Context) {
	// Auth check (if needed, userID should be in context via Middleware)
	userIDInterface, _ := c.Get("userID")
	userID, _ := userIDInterface.(uint)

	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		return
	}

	client := &Client{
		UserID: userID,
		Conn:   conn,
		Send:   make(chan []byte, 256),
	}

	MainHub.register <- client

	go client.writePump()
	go client.readPump()
}

func (c *Client) readPump() {
	defer func() {
		MainHub.unregister <- c
		c.Conn.Close()
	}()
	for {
		_, _, err := c.Conn.ReadMessage()
		if err != nil {
			break
		}
		// We don't expect messages from clients for now, but we could handle them here
	}
}

func (c *Client) writePump() {
	defer func() {
		c.Conn.Close()
	}()
	for {
		select {
		case message, ok := <-c.Send:
			if !ok {
				c.Conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}
			c.Conn.WriteMessage(websocket.TextMessage, message)
		}
	}
}

func RegisterRoutes(r *gin.RouterGroup) {
	// Optional: use auth middleware for WS upgrade if you want to identify users
	r.GET("/ws", Middleware.AuthRequired(), HandleWS)
}
