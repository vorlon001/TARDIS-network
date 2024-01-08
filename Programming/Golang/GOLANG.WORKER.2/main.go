// In this example we'll look at how to implement
// a _worker pool_ using goroutines and channels.

package main

import (
	"fmt"
	"time"
        "sync"
	//"reflect"
	"github.com/google/uuid"
)

/*********************************************************************************************************************/

var cache sync.Map

func SingletonKVStore[K comparable, V any]() KVStores[K,V] {
	hash := "SingletonKVStore"
	v, ok := cache.Load(hash)

	if ok {
		return v.(*KVStore[K,V])
	}

	v = NewKVStore[K,V]()
	v, _ = cache.LoadOrStore(hash, v)
	return v.(*KVStore[K,V])
}

/*********************************************************************************************************************/

func workerCreateVMModule(task *Task, eventBus *EventBusWorker) {
	defer panicRecoverWorker(eventBus.WorkerJobErrorBus, task.Id, task, "Error in worker")

	var m = SingletonKVStore[string, LibVirtVM]()
	//var taskCurrent Task
	for x := 1; x <= 10000; x = x + 1000 {
		//taskCurrent = *task
		content := m.GetKey(task.Id)
		eventWorkerLogs(eventBus.EventWorkerBus, fmt.Sprintf("Task.Id:%v, SingletonKVStore: %v", task.Id, content))
		/* if x > 4000 {
				panic("33333333333")
                }*/
		eventWorkerLogs(eventBus.EventWorkerBus, fmt.Sprintf("Task.Id:%v, init job: %v", task.Id, x))
		time.Sleep(time.Second)
		eventWorkerLogs(eventBus.EventWorkerBus, fmt.Sprintf("Task.ID:%v, stop job: %v", task.Id, x))
		task.Stage = x
		eventWorkerLogs(eventBus.EventWorkerBus, fmt.Sprintf("Task.ID:%v, done job: %v", task.Id, task.Stage))
	}
}

func workerDestroyVMModule(task *Task, eventBus *EventBusWorker) {
        defer panicRecoverWorker(eventBus.WorkerJobErrorBus, task.Id, task, "Error in worker")

        var m = SingletonKVStore[string, LibVirtVM]()
        //var taskCurrent Task
        for x := 1; x <= 3000; x = x + 1000 {
                //taskCurrent = *task
                content := m.GetKey(task.Id)
                eventWorkerLogs(eventBus.EventWorkerBus, fmt.Sprintf("Task.Id:%v, SingletonKVStore: %v", task.Id, content))
                /* if x > 2000 {
                                panic("33333333333")
                }*/
                eventWorkerLogs(eventBus.EventWorkerBus, fmt.Sprintf("Task.Id:%v, init job: %v", task.Id, x))
                time.Sleep(time.Second)
                eventWorkerLogs(eventBus.EventWorkerBus, fmt.Sprintf("Task.ID:%v, stop job: %v", task.Id, x))
                task.Stage = x
                eventWorkerLogs(eventBus.EventWorkerBus, fmt.Sprintf("Task.ID:%v, done job: %v", task.Id, task.Stage))
        }
}

func workerVM(id string, eventBus *EventBusWorker, jobTask WorkerJobTask) {

        var taskCurrent Task
        defer panicRecoverWorker(eventBus.WorkerErrorBus, id, &taskCurrent, "Error in worker")

        for {
                select {
                case task := <-eventBus.Jobs:
			task.SetStartTimeTask()
			task.SetDoneId(task.Id)
			task.SetWokerId(id)
			jobTask(task, eventBus)
			task.SetEndTimeTask()
			eventBus.Done <- task.Done
                case <-eventBus.QuitWorker:
                        fmt.Printf("stopping worker: %v\n", id)
                        eventWorkerLogs(eventBus.EventWorkerBus, fmt.Sprintf("stopping worker: %v", id))
                        return
                case <-eventBus.Quit:
                        fmt.Printf("stopping worker: %v\n", id)
                        eventWorkerLogs(eventBus.EventWorkerBus, fmt.Sprintf("stopping worker: %v", id))
                        return
                default:
                }
        }
}

/*********************************************************************************************************************/

type LibVirtVM struct {

        VMPath          string
        VMNAME          string  `yaml:"VMNAME"`
        VMNAME_FQDN     string  `yaml:"VMNAME_FQDN"`
        NodeId          string  `yaml:"nodeid"`
        ROOTFS_SIZE     int     `yaml:"ROOTFS_SIZE"`
        DISKID          string  `yaml:"DISKID"`
        EXT_DISK_SIZE   int     `yaml:"EXT_DISK_SIZE"`
        DetachDiskName  string
        XmlTemplate     string

        MEMORY                  int
        CORE                    int
        DISKSDA                 string
        DISKSDBCLOUDINIT        string

}

func main() {

	controllerBus := NewControllerBus()
	defer controllerBus.Close()

	var m = SingletonKVStore[string, LibVirtVM]()

	cmdCreate := Command{Command: "runWorkerJob", CommandJob: "runCreateVM", Value: workerVM, ValueArg: workerCreateVMModule}
	eventBusCreate := controllerBus.GetEventBus()
	eventBusCreate.EventWorkerCommand <- &cmdCreate
	eventBusCreate.EventWorkerCommand <- &cmdCreate

	cmdDestroy := Command{Command: "runWorkerJob", CommandJob: "runDestroyVM", Value: workerVM, ValueArg: workerDestroyVMModule}
	eventBusDestroy := controllerBus.GetEventBus()
	eventBusDestroy.EventWorkerCommand <- &cmdDestroy


	idTask_1 := uuid.New().String()
	idTask_2 := uuid.New().String()
	idTask_3 := uuid.New().String()
	idTask_4 := uuid.New().String()
	idTask_5 := uuid.New().String()
	idTask_6 := uuid.New().String()

	m.SetKey(idTask_1, &LibVirtVM{VMNAME: "nodeTask1"})
	m.SetKey(idTask_2, &LibVirtVM{VMNAME: "nodeTask2"})
	m.SetKey(idTask_3, &LibVirtVM{VMNAME: "nodeTask3"})
	m.SetKey(idTask_4, &LibVirtVM{VMNAME: "nodeTask4"})
	m.SetKey(idTask_5, &LibVirtVM{VMNAME: "nodeTask5"})
	m.SetKey(idTask_6, &LibVirtVM{VMNAME: "nodeTask6"})

	task_1 := Task{Id: idTask_1, Done: DoneEventBus{}, Command: "runCreateVM"}
	task_2 := Task{Id: idTask_2, Done: DoneEventBus{}, Command: "runCreateVM"}
	task_3 := Task{Id: idTask_3, Done: DoneEventBus{}, Command: "runCreateVM"}
	task_4 := Task{Id: idTask_4, Done: DoneEventBus{}, Command: "runDestroyVM"}
	task_5 := Task{Id: idTask_5, Done: DoneEventBus{}, Command: "runDestroyVM"}
	task_6 := Task{Id: idTask_6, Done: DoneEventBus{}, Command: "runDestroyVM"}

	tasklist := []*Task{
		&task_1,
		&task_2,
		&task_3,
		&task_4,
		&task_5,
		&task_6,
	}

	go controllerBus.ControllerRunner()

	time.Sleep(time.Second * 3)
	go func() {
		for _, j := range tasklist {
			controllerBus.InitTask(j.Id, j)
		}
	}()

	time.Sleep(40 * time.Second)
	//<-done

	cmdDestroyWorker := Command{Command: "destroyWorkerJob", CommandJob: "runDestroyVM"}
	eventBusDestroyWorker := controllerBus.GetEventBus()
	eventBusDestroyWorker.EventWorkerCommand <- &cmdDestroyWorker

        cmdDestroyCreateWorker := Command{Command: "destroyWorkerJob", CommandJob: "runCreateVM"}
        eventBusCreateWorker := controllerBus.GetEventBus()
        eventBusCreateWorker.EventWorkerCommand <- &cmdDestroyCreateWorker
	eventBusCreateWorker.EventWorkerCommand <- &cmdDestroyCreateWorker

	time.Sleep(10 * time.Second)

	eventBus := controllerBus.GetEventBus()
	eventBus.QuitWatcher <- true

	time.Sleep(10 * time.Second)
	fmt.Printf("Test is done!\n")
}
