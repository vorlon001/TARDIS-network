// In this example we'll look at how to implement
// a _worker pool_ using goroutines and channels.

package main

import (
	"time"
)

type Task struct {
	Id      string
	Stage   int
	Done    DoneEventBus
	Command string
}

func (e *Task) SetDoneId(id string) {
	e.Done.Id = id
}

func (e *Task) SetWokerId(id string) {
	e.Done.WorkerID = id
}

func (e *Task) SetStage(stage int) {
	e.Stage = stage
}

func (e *Task) SetStartTimeTask() {
	e.Done.StartTimeTask = time.Now()
}

func (e *Task) SetEndTimeTask() {
	e.Done.EndTimeTask = time.Now()
}

