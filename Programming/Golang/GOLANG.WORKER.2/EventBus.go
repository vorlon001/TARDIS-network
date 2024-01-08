// In this example we'll look at how to implement
// a _worker pool_ using goroutines and channels.

package main

import (
	"time"
)

/*********************************************************************************************************************/

type Command struct {
	Command    string
	CommandJob string
	Value      WorkerMinion
	ValueArg   WorkerJobTask
}

type DoneEventBus struct {
	StartTimeTask time.Time
	EndTimeTask   time.Time
	Id            string
	WorkerID      string
}


type EventBusWorker struct {
	Jobs               chan *Task
	EventWorkerBus     chan string
	WorkerErrorBus     chan *workerError
	WorkerJobErrorBus  chan *workerError
        Done               chan DoneEventBus
        Quit               chan bool
	QuitWorker         chan bool
}

type EventBus struct {
	Jobs               chan *Task
	JobsChan           map[string]*EventBusWorker
	Done               chan DoneEventBus
	EventWorkerCommand chan *Command
	EventWorkerBus     chan string
	WorkerErrorBus     chan *workerError
	WorkerJobErrorBus  chan *workerError
	Quit               chan bool
	QuitWatcherTask    chan bool
	QuitWatcher        chan bool
}

func NewEventBus() *EventBus {
	jobs := make(chan *Task, MaxJobsChan)
	JobsChan := make(map[string]*EventBusWorker)
	eventWorkerBus := make(chan string, MaxEventWorkerBus)
	workerErrorBus := make(chan *workerError, MaxJobsChan)
	workerJobErrorBus := make(chan *workerError, MaxJobsChan)
	eventWorkerCommand := make(chan *Command, MaxEventWorkerCommand)
	quitWatcherTask := make(chan bool)
	quitWatcher := make(chan bool)
	quit := make(chan bool)
	done := make(chan DoneEventBus)

	eventBus := EventBus{
		Jobs:               jobs,
		JobsChan:           JobsChan,
		Done:               done,
		EventWorkerCommand: eventWorkerCommand,
		EventWorkerBus:     eventWorkerBus,
		WorkerErrorBus:     workerErrorBus,
		WorkerJobErrorBus:  workerJobErrorBus,
		QuitWatcherTask:    quitWatcherTask,
		QuitWatcher:        quitWatcher,
		Quit:               quit,
	}
	return &eventBus
}

func (e *EventBus) Close() {
	close(e.Jobs)
	close(e.EventWorkerBus)
	close(e.Quit)
	close(e.Done)
	close(e.QuitWatcherTask)
	close(e.QuitWatcher)
}

