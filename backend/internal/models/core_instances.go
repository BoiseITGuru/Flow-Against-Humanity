package models

import "gorm.io/gorm"

type CoreInstance struct {
	gorm.Model      `json:"-"`
	Name            string `gorm:"not null;unique" json:"name,omitempty"`
	ClientKey       string `gorm:"not null;unique" json:"clientKey,omitempty"`
	APIKey          string `gorm:"not null;unique" json:"apiKey,omitempty"`
	NetworkID       string `gorm:"not null;unique" json:"networkID,omitempty"`
	ContainerID     string `json:"containerID,omitempty"`
	ContainerHealth string `json:"containerHealth,omitempty"` // Healthy, Unhealthy, Starting, Stopped
	ContainerStatus string `json:"containerStatus,omitempty"` // Pending, Creating, Running, Paused, Restarting, Removing, Exited, Dead
	IsManager       bool   `json:"isManager,omitempty"`
}
