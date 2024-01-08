// In this example we'll look at how to implement
// a _worker pool_ using goroutines and channels.

package main

import (
	"log"
	"runtime"
)

func panicRecover() {
	if r := recover(); r != nil {
		log.Printf("Internal error: %v", r)
		buf := make([]byte, 1<<16)
		stackSize := runtime.Stack(buf, true)
		log.Printf("--------------------------------------------------------------------------------")
		log.Printf("Internal error: %s\n", string(buf[0:stackSize]))
		log.Printf("--------------------------------------------------------------------------------")
	}
}

