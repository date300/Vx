package Realtime

import (
	"encoding/json"
	"sync"

	"github.com/gorilla/websocket"
)

// Client represents a single connected user
type Client struct {
	UserID uint
	Conn   *websocket.Conn
	Send   chan []byte
}

// Hub manages all connected clients and message broadcasting
type Hub struct {
	clients    map[uint][]*Client
	register   chan *Client
	unregister chan *Client
	broadcast  chan BroadcastMessage
	mu         sync.RWMutex
}

type BroadcastMessage struct {
	Type    string      `json:"type"`
	Payload interface{} `json:"payload"`
	Target  uint        `json:"target,omitempty"` // 0 means broadcast to all
}

func NewHub() *Hub {
	return &Hub{
		clients:    make(map[uint][]*Client),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		broadcast:  make(chan BroadcastMessage),
	}
}

func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.mu.Lock()
			h.clients[client.UserID] = append(h.clients[client.UserID], client)
			h.mu.Unlock()

		case client := <-h.unregister:
			h.mu.Lock()
			if clients, ok := h.clients[client.UserID]; ok {
				for i, c := range clients {
					if c == client {
						h.clients[client.UserID] = append(clients[:i], clients[i+1:]...)
						break
					}
				}
				if len(h.clients[client.UserID]) == 0 {
					delete(h.clients, client.UserID)
				}
				close(client.Send)
			}
			h.mu.Unlock()

		case message := <-h.broadcast:
			msgBytes, _ := json.Marshal(message)
			h.mu.RLock()
			if message.Target > 0 {
				// Send to specific user
				if clients, ok := h.clients[message.Target]; ok {
					for _, client := range clients {
						select {
						case client.Send <- msgBytes:
						default:
							// Handle slow client if necessary
						}
					}
				}
			} else {
				// Broadcast to all
				for _, clients := range h.clients {
					for _, client := range clients {
						select {
						case client.Send <- msgBytes:
						default:
						}
					}
				}
			}
			h.mu.RUnlock()
		}
	}
}

func (h *Hub) Broadcast(msg BroadcastMessage) {
	h.broadcast <- msg
}

var MainHub = NewHub()
