// In this example we'll look at how to implement
// a _worker pool_ using goroutines and channels.

package main

const MaxJobsChan = 100
const MaxEventWorkerCommand = 100
const MaxEventWorkerBus = 10000

