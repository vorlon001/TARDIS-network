// In this example we'll look at how to implement
// a _worker pool_ using goroutines and channels.

package main

import (
	"fmt"
	"time"

	"github.com/google/uuid"
)

/*********************************************************************************************************************/

type ControllerBus struct {
	tasks    *map[string]*Task
	eventBus *EventBus
	Task     chan *Task
	Quit     chan bool
}

func NewControllerBus() *ControllerBus {
	Quit := make(chan bool)
	taskChan := make(chan *Task)
	tasks := make(map[string]*Task)
	eventBus := NewEventBus()

	controllerBus := ControllerBus{
		eventBus: eventBus,
		tasks:    &tasks,
		Task:     taskChan,
		Quit:     Quit,
	}
	return &controllerBus
}

func (e *ControllerBus) GetEventBus() *EventBus {
	return e.eventBus
}

func (e *ControllerBus) GetTask(id string) *Task {
	return (*e.tasks)[id]
}

func (e *ControllerBus) addTask(id string, task *Task) {
	(*e.tasks)[id] = task
}

func (e *ControllerBus) runTask(id string) {
	e.eventBus.Jobs <- (*e.tasks)[id]
}

func (e *ControllerBus) InitTask(id string, task *Task) {
	e.addTask(id, task)
	e.runTask(id)
}

func (e *ControllerBus) Close() {
	e.eventBus.Close()
	close(e.Quit)
	close(e.Task)
}

func (e *ControllerBus) WatcherTask() {
	defer panicRecoverWorker(e.eventBus.WorkerErrorBus, "", &Task{}, "Error in WatcherTask")
	for {
		select {
		default:
			for k, v := range *e.tasks {
				eventWorkerLogs(e.eventBus.EventWorkerBus, fmt.Sprintf("WatcherTask id: %v value:%#v", k, v))
			}
			time.Sleep(time.Second)
		case <-e.eventBus.QuitWatcherTask:
			eventWorkerLogs(e.eventBus.EventWorkerBus, fmt.Sprintf("stopping WatcherTask"))
			return
		}
	}
}

func (e *ControllerBus) EventBusRunner() {
	defer panicRecover()
	workerTemplate := make(map[string]*Command)
	for {
		select {
		case j := <-e.eventBus.Jobs:
			chanJob := e.eventBus.JobsChan[j.Command].Jobs
			chanJob <- j
		case j := <-e.eventBus.EventWorkerCommand:
			switch j.Command {
			case "destroyWorkerJob":
				fmt.Printf("eventWorkerBus:eventWorkerCommand:%v\n", j)
				chanJob := e.eventBus.JobsChan[j.CommandJob].QuitWorker
				chanJob <- true
			case "runWorkerJob":
				if _, ok := workerTemplate[j.CommandJob]; !ok {
					workerTemplate[j.CommandJob] = j
					eventBusWorker := EventBusWorker{
												Done: e.eventBus.Done,
												Quit: e.eventBus.Quit,
												QuitWorker: make(chan bool),
												Jobs: make(chan *Task, MaxJobsChan),
												EventWorkerBus: e.eventBus.EventWorkerBus,
												WorkerJobErrorBus: e.eventBus.WorkerJobErrorBus,
												WorkerErrorBus: e.eventBus.WorkerErrorBus,
												}
					e.eventBus.JobsChan[j.CommandJob] = &eventBusWorker
				}
				f := (j.Value)
				r := (j.ValueArg)
				uuidWorker := uuid.New().String()
				fmt.Printf("eventWorkerBus:eventWorkerCommand:%v uuidWorker:%v\n", j, uuidWorker)
				go f(uuidWorker, e.eventBus.JobsChan[j.CommandJob], r)
			default:
				fmt.Printf("CMD not found%s.\n", j.Command)
			}
		case j := <-e.eventBus.EventWorkerBus:
			fmt.Printf("eventWorkerBus:WorkerBus:%v\n", j)
		case j := <-e.eventBus.WorkerJobErrorBus:
			fmt.Printf("eventWorkerBus:WorkerJobErrorBus:%v\n", j)
		case j := <-e.eventBus.WorkerErrorBus:
			fmt.Printf("eventWorkerBus:WorkerErrorBus:%v\n", j)
			fmt.Printf("eventWorkerBus:WorkerErrorBus:%v\n", j.Err)
			fmt.Printf("eventWorkerBus:WorkerErrorBus:%v\n", j.Dump)
			e.eventBus.EventWorkerCommand <- workerTemplate[j.GetTask().Command]
		case j := <-e.eventBus.Done:
			fmt.Printf("eventWorkerBus:DoneWatcherTask:%#v\n", j)
		case <-e.eventBus.QuitWatcher:
			return
		}
	}
}

func (e *ControllerBus) ControllerBusRunner() {
	defer panicRecover()
	for {
		select {
		case j := <-e.Task:
			fmt.Printf(">!!!!!!e.InitTask>%#v\n", j)
			e.InitTask(j.Id, j)
		case <-e.Quit:
			return
		}
	}
}

func (e *ControllerBus) ControllerRunner() {
	defer panicRecover()
	go e.ControllerBusRunner()
	go e.WatcherTask()
	go e.EventBusRunner()
}

