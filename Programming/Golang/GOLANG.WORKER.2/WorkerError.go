// In this example we'll look at how to implement
// a _worker pool_ using goroutines and channels.

package main

import (
	"fmt"
	"log"
	"runtime"
)


type workerError struct {
	workerId string
	task     *Task
	Err      string
	Dump     string
}

func (e *workerError) GetTask() *Task {
	return e.task
}

func (e *workerError) Error() string {
	return fmt.Sprintf("workerId:%s Task::%#v Err:%s", e.workerId, e.task, e.Err)
}

func panicRecoverWorker(i chan<- *workerError, workerId string, task *Task, Err string) {
	if r := recover(); r != nil {
		log.Printf("Run panicRecoverWorker(), Internal error: %v", r)
		buf := make([]byte, 1<<16)
		stackSize := runtime.Stack(buf, true)
		i <- &workerError{
			workerId: workerId,
			task:     task,
			Dump:     string(buf[0:stackSize]),
			Err:      fmt.Sprintf("Internal error: %v", r),
		}
	}
}

func eventWorkerLogs(eventWorkerBus chan<- string, logs string) {
	eventWorkerBus <- logs
}

