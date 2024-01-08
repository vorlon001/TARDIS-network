// https://go.dev/play/p/SfGDZXdI9WO

package main

import "fmt"

type yieldFn func(interface{}) (stopIterating bool)
type mapperFn func(yieldFn)
type iteratorFn func() (value interface{}, done bool)
type cancelFn func()

func mapperToIterator(m mapperFn) (iteratorFn, cancelFn) {
	generatedValues := make(chan interface{}, 1)
	stopCh := make(chan interface{}, 1)
	go func() {
		m(func(obj interface{}) bool {
			select {
			case <-stopCh:
				return false
			case generatedValues <- obj:
				return true
			}
		})
		close(generatedValues)
	}()
	iter := func() (value interface{}, notDone bool) {
		value, notDone = <-generatedValues
		return
	}
	return iter, func() {
		stopCh <- nil
	}
}

func main() {
	myMapper := func(yield yieldFn) {
		/*for i := 0; i < 5; i++ {
			if keepGoing := yield(i); !keepGoing {
				return
			}
		}*/
		_ = yield(1)
		_ = yield(2)
		_ = yield(3)
		_ = yield(4)

	}
	iter, cancel := mapperToIterator(myMapper)
	defer cancel()
	for value, notDone := iter(); notDone; value, notDone = iter() {
		fmt.Printf("value: %d\n", value.(int))
	}
}
