// In this example we'll look at how to implement
// a _worker pool_ using goroutines and channels.

package main

type WorkerMinion func(string, *EventBusWorker, WorkerJobTask)

type WorkerJobTask func(*Task, *EventBusWorker)
