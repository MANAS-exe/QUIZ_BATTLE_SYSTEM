package redis

import (
	"fmt"
	"log"
	"time"

	"github.com/gomodule/redigo/redis"
)

// NewPool creates a Redis connection pool.
func NewPool(addr string) *redis.Pool {
	return &redis.Pool{
		MaxIdle:     10,
		MaxActive:   100,
		IdleTimeout: 240 * time.Second,
		Wait:        true,

		Dial: func() (redis.Conn, error) {
			conn, err := redis.Dial(
				"tcp",
				addr,
				redis.DialConnectTimeout(5*time.Second),
				redis.DialReadTimeout(3*time.Second),
				redis.DialWriteTimeout(3*time.Second),
			)
			if err != nil {
				return nil, fmt.Errorf("redis dial %s: %w", addr, err)
			}
			return conn, nil
		},

		TestOnBorrow: func(c redis.Conn, t time.Time) error {
			if time.Since(t) < time.Minute {
				return nil
			}
			_, err := c.Do("PING")
			if err != nil {
				log.Printf("⚠️  Redis health check failed: %v", err)
			}
			return err
		},
	}
}
