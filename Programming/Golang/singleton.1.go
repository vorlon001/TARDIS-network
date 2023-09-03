// You can edit this code!
// Click here and start typing.
package main

import (
	"fmt"
	"reflect"
	"sync"
)

var cache sync.Map

// Singleton returns a singleton of T.
func Singleton[T any]() (t *T) {
	hash := reflect.TypeOf(t)
	v, ok := cache.Load(hash)

	if ok {
		return v.(*T)
	}

	v = new(T)
	v, _ = cache.LoadOrStore(hash, v)
	return v.(*T)
}

type MyType struct {
	field int
}

func main() {
	v1 := Singleton[MyType]()
	v1.field = 123

	v2 := Singleton[MyType]()
	println(v2.field) // Output: 123
	fmt.Println("Hello, 世界")
}
