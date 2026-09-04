// Package Realtime owns the Socket.IO server that lets the backend push
// near-real-time commands ("open the settings screen", "check for an
// update", ...) to a specific kiosk without waiting on a polling interval.
//
// New command *types* never require touching this file: they are just
// string identifiers agreed between this backend and the Flutter app (see
// RemoteCommandBindings on the Flutter side). Hub only knows how to
// authenticate a connection and route a `{type, payload}` envelope to the
// right device's room - it has no idea what any individual command does.
package Realtime

import (
	"Back/Auth"
	"Back/DTO"
	Services "Back/Service"
	"fmt"
	"log"
	"net/http"
	"sync"

	"github.com/zishang520/socket.io/v2/socket"
)

type Hub struct {
	io            *socket.Server
	jwtService    Auth.JWTService
	deviceService Services.DeviceService

	mu        sync.Mutex
	connected map[uint]int // deviceID -> live socket count (usually 0 or 1)
}

func NewHub(jwtService Auth.JWTService, deviceService Services.DeviceService) *Hub {
	h := &Hub{
		io:            socket.NewServer(nil, nil),
		jwtService:    jwtService,
		deviceService: deviceService,
		connected:     map[uint]int{},
	}

	h.io.Use(h.authenticate)
	h.io.On("connection", h.onConnection)

	return h
}

// Handler exposes the Socket.IO endpoint as a standard http.Handler so it
// mounts on the existing Echo instance next to every REST route.
func (h *Hub) Handler() http.Handler {
	return h.io.ServeHandler(nil)
}

func deviceRoom(deviceID uint) socket.Room {
	return socket.Room(fmt.Sprintf("device:%d", deviceID))
}

// authenticate runs once per incoming connection, before it's accepted.
// It mirrors AuthMiddleware.Authenticate() for REST calls (same JWT
// service, same token) - only a device already logged in from the Flutter
// app (see AuthState) can hold a socket connection, exactly like every
// other authenticated endpoint in this API.
func (h *Hub) authenticate(client *socket.Socket, next func(*socket.ExtendedError)) {
	auth, _ := client.Handshake().Auth.(map[string]interface{})
	token, _ := auth["token"].(string)
	if token == "" {
		next(socket.NewExtendedError("توکن ارسال نشده است", nil))
		return
	}

	claims, err := h.jwtService.ValidateAccessToken(token)
	if err != nil {
		next(socket.NewExtendedError("توکن نامعتبر یا منقضی‌شده است", nil))
		return
	}

	device, err := h.deviceService.GetByUserID(claims.UserID)
	if err != nil {
		next(socket.NewExtendedError("دستگاه متناظر با این توکن یافت نشد", nil))
		return
	}

	client.SetData(device.ID)
	next(nil)
}

func (h *Hub) onConnection(clients ...any) {
	client := clients[0].(*socket.Socket)
	deviceID, ok := client.Data().(uint)
	if !ok {
		client.Disconnect(true)
		return
	}

	client.Join(deviceRoom(deviceID))
	h.markConnected(deviceID)

	client.On("disconnect", func(...any) {
		h.markDisconnected(deviceID)
	})
}

func (h *Hub) markConnected(deviceID uint) {
	h.mu.Lock()
	h.connected[deviceID]++
	first := h.connected[deviceID] == 1
	h.mu.Unlock()

	if first {
		h.touchDeviceStatus(deviceID, "active")
	}
}

func (h *Hub) markDisconnected(deviceID uint) {
	h.mu.Lock()
	h.connected[deviceID]--
	last := h.connected[deviceID] <= 0
	if last {
		delete(h.connected, deviceID)
	}
	h.mu.Unlock()

	if last {
		h.touchDeviceStatus(deviceID, "offline")
	}
}

func (h *Hub) touchDeviceStatus(deviceID uint, status string) {
	if err := h.deviceService.UpdateDevice(deviceID, DTO.UpdateDevice{Status: &status}); err != nil {
		log.Println("[Realtime] به‌روزرسانی وضعیت دستگاه ناموفق:", err)
	}
}

func (h *Hub) IsConnected(deviceID uint) bool {
	h.mu.Lock()
	defer h.mu.Unlock()
	return h.connected[deviceID] > 0
}

// SendCommand pushes a `{type, payload}` command to every socket currently
// connected for the given device. There is intentionally no queueing/retry
// yet - if the device isn't connected right now, this returns an error so
// the caller (an admin action, for now) can tell the operator it wasn't
// delivered instead of silently doing nothing.
func (h *Hub) SendCommand(deviceID uint, commandType string, payload map[string]interface{}) error {
	if !h.IsConnected(deviceID) {
		return fmt.Errorf("دستگاه در حال حاضر به سرور متصل نیست")
	}

	if payload == nil {
		payload = map[string]interface{}{}
	}

	return h.io.To(deviceRoom(deviceID)).Emit("command", map[string]interface{}{
		"type":    commandType,
		"payload": payload,
	})
}
