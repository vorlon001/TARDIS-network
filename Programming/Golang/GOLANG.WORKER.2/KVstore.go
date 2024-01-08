// base on https://github.com/jellydator/ttlcache/blob/v3/cache.go#L247
// https://go.dev/play/p/8KrYOlA3NA1

package main

import (
	//"fmt"
	"sync"
	//"time"
)

type Metrics struct {
	// Insertions specifies how many items were inserted.
	Insertions uint64

	// Insertions specifies how many items were reads.
	Reads uint64

	// Hits specifies how many items were successfully retrieved
	// from the cache.
	// Retrievals made with a loader function are not tracked.
	Hits uint64

	// Misses specifies how many items were not found in the cache.
	// Retrievals made with a loader function are considered misses as
	// well.
	Misses uint64

	// Evictions specifies how many items were removed from the
	// cache.
	Evictions uint64
}

type KVStores[K comparable, V any] interface {
	Has(key K) bool
	Len() int
	Keys() []K
	DeleteKey(id K)
	SetKey(id K, value *V)
	GetKey(id K) *V
	GetMetrics() Metrics
	DeepCopy() map[K]*V
}

type KVStore[K comparable, V any] struct {
	value     map[K]*V
	mu        sync.RWMutex
	metricsMu sync.RWMutex
	metrics   Metrics
}

func (kv *KVStore[K, V]) metricsInsertions() {
	kv.metricsMu.Lock()
	kv.metrics.Insertions++
	kv.metricsMu.Unlock()
}

func (kv *KVStore[K, V]) metricsReads() {
	kv.metricsMu.Lock()
	kv.metrics.Reads++
	kv.metricsMu.Unlock()
}

func (kv *KVStore[K, V]) metricsHits() {
	kv.metricsMu.Lock()
	kv.metrics.Hits++
	kv.metricsMu.Unlock()
}

func (kv *KVStore[K, V]) metricsMisses() {
	kv.metricsMu.Lock()
	kv.metrics.Misses++
	kv.metricsMu.Unlock()
}

func (kv *KVStore[K, V]) metricsEvictions() {
	kv.metricsMu.Lock()
	kv.metrics.Evictions += uint64(1)
	kv.metricsMu.Unlock()
}

func (kv *KVStore[K, V]) setKey(id K, value *V) {
	kv.mu.Lock()
	kv.value[id] = value
	kv.mu.Unlock()

	kv.metricsInsertions()
	kv.metricsHits()
}

func (kv *KVStore[K, V]) SetKey(id K, value *V) {
	kv.setKey(id, value)
}
func (kv *KVStore[K, V]) deleteKey(id K) {
	kv.mu.Lock()
	delete(kv.value, id)
	kv.mu.Unlock()

	kv.metricsEvictions()

	kv.metricsHits()
}
func (kv *KVStore[K, V]) DeleteKey(id K) {
	kv.deleteKey(id)
}

func (kv *KVStore[K, V]) getKey(id K) *V {
	kv.mu.RLock()
	defer kv.mu.RUnlock()

	kv.metricsHits()
	kv.metricsReads()

	elem := kv.value[id]
	if elem == nil {
		kv.metricsMisses()
		return nil
	}
	return elem
}

func (kv *KVStore[K, V]) GetKey(id K) *V {
	return kv.getKey(id)
}

func (kv *KVStore[K, V]) GetMetrics() Metrics {
	return kv.metrics
}

func (kv *KVStore[K, V]) Has(key K) bool {
	kv.mu.RLock()
	defer kv.mu.RUnlock()
	_, ok := kv.value[key]
	return ok
}

func (kv *KVStore[K, V]) Len() int {
	kv.mu.RLock()
	defer kv.mu.RUnlock()

	return len(kv.value)
}

func (kv *KVStore[K, V]) Keys() []K {
	kv.mu.RLock()
	defer kv.mu.RUnlock()

	res := make([]K, 0, len(kv.value))
	for k := range kv.value {
		res = append(res, k)
	}

	return res
}

func (kv *KVStore[K, V]) DeepCopy() map[K]*V {
	kv.mu.RLock()
	defer kv.mu.RUnlock()

	items := make(map[K]*V, len(kv.value))
	for k := range kv.value {
		item := kv.getKey(k)
		if item != nil {
			items[k] = item
		}
	}

	return items
}

func NewKVStore[K comparable, V any]() KVStores[K, V] {
	kv := KVStore[K, V]{
		value: make(map[K]*V),
	}
	return &kv
}

/*
func main() {
	var m = NewKVStore[int, int]()

	// write goroutine
	go func() {
		for i := 0; i < 10000; i++ {
			m.SetKey(i, &i)
		}
		fmt.Printf("DONE1\n")
	}()

	// read goroutine
	go func() {
		for i := 10000; i > 0; i-- {
			_ = m.GetKey(i)

		}
		fmt.Printf("DONE2\n")
	}()

	// another write go routine
	go func() {
		for i := 20000; i > 10000; i-- {
			m.SetKey(i, &i)

		}
		fmt.Printf("DONE3\n")
	}()

	// another read go routine
	go func() {
		for i := 20000; i > 10000; i-- {
			_ = m.GetKey(i)

		}
		fmt.Printf("DONE3\n")
	}()

	// another Delete go routine
	go func() {
		for i := 4000; i > 2000; i-- {
			m.DeleteKey(i)

		}
		fmt.Printf("DONE3\n")
	}()

	fmt.Printf("DONE4\n")
	time.Sleep(time.Second * 3)
	fmt.Printf("DONE5 - %#v\n", m.GetMetrics())
}
*/
