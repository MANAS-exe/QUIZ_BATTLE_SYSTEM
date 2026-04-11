package redis

import (
	"errors"
	"fmt"

	"github.com/gomodule/redigo/redis"
	"github.com/google/uuid"
)

const (
	lockTTLSeconds = 10
	lockKeyPrefix  = "room:lock:"
)

// ErrLockNotAcquired is returned when another instance already holds the lock.
var ErrLockNotAcquired = errors.New("lock not acquired: another instance holds it")

// releaseScript atomically checks the lock value matches the owner before deleting.
// Prevents one goroutine from releasing another's lock if the TTL expired in between.
var releaseScript = redis.NewScript(1, `
if redis.call('GET', KEYS[1]) == ARGV[1] then
	return redis.call('DEL', KEYS[1])
else
	return 0
end
`)

// AcquireLock tries to set room:lock:{roomID} using SET NX EX (atomic).
// Returns an owner token on success. Pass this token to ReleaseLock.
func AcquireLock(pool *redis.Pool, roomID string) (ownerToken string, err error) {
	conn := pool.Get()
	defer conn.Close()

	if err := conn.Err(); err != nil {
		return "", fmt.Errorf("redis connection error: %w", err)
	}

	key := lockKeyPrefix + roomID
	token := uuid.New().String()

	reply, err := redis.String(conn.Do("SET", key, token, "NX", "EX", lockTTLSeconds))
	if err != nil {
		if errors.Is(err, redis.ErrNil) {
			return "", ErrLockNotAcquired
		}
		return "", fmt.Errorf("SET NX EX %s: %w", key, err)
	}
	if reply != "OK" {
		return "", ErrLockNotAcquired
	}
	return token, nil
}

// ReleaseLock atomically deletes room:lock:{roomID} only if the value matches
// the owner token. This prevents releasing a lock held by another goroutine.
func ReleaseLock(pool *redis.Pool, roomID, ownerToken string) error {
	conn := pool.Get()
	defer conn.Close()

	if err := conn.Err(); err != nil {
		return fmt.Errorf("redis connection error: %w", err)
	}

	key := lockKeyPrefix + roomID

	_, err := releaseScript.Do(conn, key, ownerToken)
	if err != nil {
		return fmt.Errorf("release lock %s: %w", key, err)
	}
	return nil
}
