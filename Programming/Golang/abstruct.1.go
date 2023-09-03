// You can edit this code!
// Click here and start typing.
package main

import (
	"fmt"
	"reflect"
)

/*********** PART 1 ***********/
type AbstructMethod func(in []reflect.Value) []reflect.Value
type GetMenuElement func() (*string, error)

type ServiceOrder struct{}

func (f *ServiceOrder) RunService1(name string) (*string, error) {
	message := fmt.Sprintf("RunService1: %s", name)
	return &message, nil
}

func (f *ServiceOrder) RunService2(name string, value int) (*string, error) {
	message := fmt.Sprintf("RunService2: %s, %d", name, value)
	return &message, nil
}

/*********** PART 2 ***********/
type ServiceOrders struct {
	abstructMethods map[string]AbstructMethod
}

func (s *ServiceOrders) RunOrder(name string, args ...interface{}) (*string, error) {
	result := s.abstructMethods[name]

	argsReflect := make([]reflect.Value, 0)

	for _, v := range args {
		argsReflect = append(argsReflect, reflect.ValueOf(v))
	}
	val := result(argsReflect)

	value0 := val[0].Interface().(*string)
	var value1 error
	if val[1].Interface() != nil {
		value1 = val[1].Interface().(error)
	} else {
		value1 = nil
	}
	fmt.Printf("=>%#v\n", *value0)
	return value0, value1
}

func (s *ServiceOrders) RunOrderEvent(name string, args ...interface{}) []interface{} {
	result := s.abstructMethods[name]

	argsReflect := make([]reflect.Value, 0)

	for _, v := range args {
		argsReflect = append(argsReflect, reflect.ValueOf(v))
	}
	val := result(argsReflect)

	valueReturns := make([]interface{}, 0)
	for _, v := range val {
		i := v.Interface()

		switch v := i.(type) {
		case int:
			value := i.(int)
			valueReturns = append(valueReturns, value)
		case nil:
			valueReturns = append(valueReturns, nil)
		case *string:
			value := i.(*string)
			valueReturns = append(valueReturns, value)
		case string:
			value := i.(string)
			valueReturns = append(valueReturns, value)
		case error:
			value := i.(error)
			valueReturns = append(valueReturns, value)
		default:
			fmt.Printf("I don't know about type %T!\n", v)
		}
	}

	fmt.Printf("=>%#v\n", valueReturns)
	return valueReturns
}

func (s *ServiceOrders) GetServiceOrder(serviceOrder *ServiceOrder) {

	serviceOrderType := reflect.TypeOf(serviceOrder)
	serviceOrderValue := reflect.ValueOf(serviceOrder)

	cmd := map[string]AbstructMethod{}

	for i := 0; i < serviceOrderType.NumMethod(); i++ {
		method := serviceOrderType.Method(i)
		val := serviceOrderValue.MethodByName(method.Name).Call
		cmd[method.Name] = val
	}

	s.abstructMethods = cmd
}

func NewServiceOrders(serviceOrder *ServiceOrder) *ServiceOrders {
	serviceOrders := ServiceOrders{}
	serviceOrders.GetServiceOrder(serviceOrder)
	return &serviceOrders
}

/*********** PART 3 ***********/

func main() {

	serviceOrder := ServiceOrder{}
	serviceOrders := NewServiceOrders(&serviceOrder)
	fmt.Printf("DEBUG: %v\n", serviceOrders)

	result, err := serviceOrders.RunOrder("RunService1", "sdfsdfsdf 345b354g")
	fmt.Printf("=>%#v %#v\n", *result, err)

	result, err = serviceOrders.RunOrder("RunService2", "sdfsdfsdfv24 erdsfs", 23425234)
	fmt.Printf("=>%#v %#v\n", *result, err)

	resultEvent := serviceOrders.RunOrderEvent("RunService2", "sdfsdfsdfv24 erdsfs", 23425234)
	fmt.Printf("=>%#v\n", resultEvent)
}
