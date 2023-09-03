/* 

https://go.dev/play/p/lX8wrDu_es8
https://go.dev/play/p/IZSMfBPDwLh

*/

package main

import (
	"fmt"
	"reflect"
	"time"
	"sync"
	"net"
	"gopkg.in/yaml.v3"
	"github.com/google/uuid"
)


/*********** PART 0 ***********/

type TransactionOrder struct{
	TimeOrder	time.Time
	NameOrder	string
	Uuid		uuid.UUID
	OrderUUID	uuid.UUID
	Device		string
	Path		string
	XMLDomainconfig	string
	MigrateTo	uuid.UUID
}


func (o *TransactionOrder) GetUUID() uuid.UUID {
	return o.Uuid
}

func (o *TransactionOrder) GetOrderUUID() uuid.UUID {
        return o.Uuid
}

func (o *TransactionOrder) GetDevice() string {
        return o.Device
}

func (o *TransactionOrder) GetPath() string {
        return o.Path
}

/*********** PART 0 ***********/

type TransactionStore map[uuid.UUID]TransactionOrder

func (o *TransactionStore) AddToStore(transaction *TransactionOrder) {
	uuid := transaction.GetUUID()
        (*o)[uuid] = *transaction
}

func (o *TransactionStore) GetFromStore(uuid uuid.UUID) TransactionOrder {
	return (*o)[uuid]
}


/*********** PART 0 ***********/

type CloudDomain struct{
	InitOrder		time.Time
	LastOrderInit		time.Time
        LastOrderDone           time.Time
	LastTransaction		uuid.UUID
        Domain                  string
	XMLDomainconfig		string
	ComputeNodeUUID		uuid.UUID
	NetworkUUID		uuid.UUID
	Transactions		[]uuid.UUID
        UUID                    uuid.UUID
}


func (o *CloudDomain) GetUUID() uuid.UUID {
        return o.UUID
}

func (o *CloudDomain) GetOrderUUID() uuid.UUID {
        return o.UUID
}

func (o *CloudDomain) GetDomain() string {
        return o.Domain
}


/*********** PART 0 ***********/


type CloudDomainStore map[uuid.UUID]*CloudDomain

func (o *CloudDomainStore) AddToStore(domain *CloudDomain) {
        (*o)[(*domain).GetUUID()] =  domain
}

func (o *CloudDomainStore) GetFromStore(uuid uuid.UUID) *CloudDomain {
        return (*o)[uuid]
}

/*********** PART 0 ***********/

type CloudDomainStoreByName map[string]uuid.UUID

func (o *CloudDomainStoreByName) AddToStore(domain *CloudDomain) {
        (*o)[(*domain).GetDomain()] = (*domain).GetUUID()
}

func (o *CloudDomainStoreByName) GetFromStore(domain string) uuid.UUID {
        return (*o)[domain]
}



/*********** PART 1 ***********/
type AbstructMethod func(in []reflect.Value) []reflect.Value
type GetMenuElement func() (bool, error)

type ServiceOrderInterface interface {
	InitDomain(name uuid.UUID, eventID uuid.UUID) (bool, error)
	CreateBootDisk(name uuid.UUID, eventID uuid.UUID) (bool, error)
	CreateUserData(name uuid.UUID, eventID uuid.UUID) (bool, error)
	CreateNetworkDate(name uuid.UUID, eventID uuid.UUID) (bool, error)
	FirstStartDomain(name uuid.UUID, eventID uuid.UUID) (bool, error)
	IsStopDomainOne(name uuid.UUID, eventID uuid.UUID) (bool, error)
	StartDomainOne(name uuid.UUID, eventID uuid.UUID) (bool, error)
	IsStartDomainOne(name uuid.UUID, eventID uuid.UUID) (bool, error)
	RemoveCloudISO(name uuid.UUID, eventID uuid.UUID) (bool, error)
	ConfigureDomain(name uuid.UUID, eventID uuid.UUID) (bool, error)
	RebootDomain(name uuid.UUID, eventID uuid.UUID) (bool, error)
	IsStartDomainTwo(name uuid.UUID, eventID uuid.UUID) (bool, error)
	Done(name uuid.UUID, eventID uuid.UUID) (bool, error)


	InitStartDomain(name uuid.UUID, eventID uuid.UUID) (bool, error)
	StartDomain(name uuid.UUID, eventID uuid.UUID) (bool, error)

	CreateDisk(name uuid.UUID, eventID uuid.UUID) (bool, error)

        InitAttachDisk(name uuid.UUID, eventID uuid.UUID) (bool, error)
        InitDeattachDisk(name uuid.UUID, eventID uuid.UUID) (bool, error)

        AttachDisk(name uuid.UUID, eventID uuid.UUID) (bool, error)
        DeattachDisk(name uuid.UUID, eventID uuid.UUID) (bool, error)

        InitAttachNetworkDevice(name uuid.UUID, eventID uuid.UUID) (bool, error)
        InitDeattachNetworkDevice(name uuid.UUID, eventID uuid.UUID) (bool, error)

        AttachNetworkDevice(name uuid.UUID, eventID uuid.UUID) (bool, error)
        DeattachNetworkDevice(name uuid.UUID, eventID uuid.UUID) (bool, error)

        InitDestroyDomain(name uuid.UUID, eventID uuid.UUID) (bool, error)
        DestroyDomain(name uuid.UUID, eventID uuid.UUID) (bool, error)

        InitSoftRebootDomain(name uuid.UUID, eventID uuid.UUID) (bool, error)
        InitHardRebootDomain(name uuid.UUID, eventID uuid.UUID) (bool, error)
        InitShutdownDomain(name uuid.UUID, eventID uuid.UUID) (bool, error)

        SoftRebootDomain(name uuid.UUID, eventID uuid.UUID) (bool, error)
        HardRebootDomain(name uuid.UUID, eventID uuid.UUID) (bool, error)
        ShutdownDomain(name uuid.UUID, eventID uuid.UUID) (bool, error)

        InitMachinePause(name uuid.UUID, eventID uuid.UUID) (bool, error)
        InitMachineResume(name uuid.UUID, eventID uuid.UUID) (bool, error)
        InitMachineMigrate(name uuid.UUID, eventID uuid.UUID) (bool, error)

        MachinePause(name uuid.UUID, eventID uuid.UUID) (bool, error)
        MachineResume(name uuid.UUID, eventID uuid.UUID) (bool, error)
        MachineMigrate(name uuid.UUID, eventID uuid.UUID) (bool, error)


	StateReboot(name uuid.UUID, eventID uuid.UUID) (bool, error)
        StateDestroy(name uuid.UUID, eventID uuid.UUID) (bool, error)
        StateRunning(name uuid.UUID, eventID uuid.UUID) (bool, error)
        StatePause(name uuid.UUID, eventID uuid.UUID) (bool, error)
        StateStop(name uuid.UUID, eventID uuid.UUID) (bool, error)
        StateError(name uuid.UUID, eventID uuid.UUID) (bool, error)

}

type ServiceOrder struct{}

func NewServiceOrder() ServiceOrderInterface {
	return &ServiceOrder{}
}

func (f *ServiceOrder) InitDomain(name uuid.UUID, eventID uuid.UUID) (bool, error) {
	message := fmt.Sprintf("DEBUG: Event ServiceOrder. InitDomain: vm:%s transaction:%s", name, eventID)
	fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)


        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        //GetInstanceTransactionStore().AddToStore(transaction)

	return true, nil
}

func (f *ServiceOrder) CreateBootDisk(name uuid.UUID, eventID uuid.UUID) (bool, error) {
	message := fmt.Sprintf("DEBUG: Event ServiceOrder. CreateBootDisk: vm:%s transaction:%s", name, eventID)
	fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

	return true, nil
}

func (f *ServiceOrder) CreateUserData(name uuid.UUID, eventID uuid.UUID) (bool, error) {
	message := fmt.Sprintf("DEBUG: Event ServiceOrder. CreateUserData: vm:%s transaction:%s", name, eventID)
	fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

	return true, nil
}

func (f *ServiceOrder) CreateNetworkDate(name uuid.UUID, eventID uuid.UUID) (bool, error) {
	message := fmt.Sprintf("DEBUG: Event ServiceOrder. CreateNetworkDate: vm:%s transaction:%s", name, eventID)
	fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

	return true, nil
}

func (f *ServiceOrder) FirstStartDomain(name uuid.UUID, eventID uuid.UUID) (bool, error) {
	message := fmt.Sprintf("DEBUG: Event ServiceOrder. FirstStartDomain: vm:%s transaction:%s", name, eventID)
	fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

	return true, nil
}

func (f *ServiceOrder) IsStopDomainOne(name uuid.UUID, eventID uuid.UUID) (bool, error) {
	message := fmt.Sprintf("DEBUG: Event ServiceOrder. IsStopDomainOne: vm:%s transaction:%s", name, eventID)
	fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

	return true, nil
}

func (f *ServiceOrder) StartDomainOne(name uuid.UUID, eventID uuid.UUID) (bool, error) {
	message := fmt.Sprintf("DEBUG: Event ServiceOrder. StartDomainOne: vm:%s transaction:%s", name, eventID)
	fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

	return true, nil
}

func (f *ServiceOrder) IsStartDomainOne(name uuid.UUID, eventID uuid.UUID) (bool, error) {
	message := fmt.Sprintf("DEBUG: Event ServiceOrder. IsStartDomainOne: vm:%s transaction:%s", name, eventID)
	fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

	return true, nil
}

func (f *ServiceOrder) RemoveCloudISO(name uuid.UUID, eventID uuid.UUID) (bool, error) {
	message := fmt.Sprintf("DEBUG: Event ServiceOrder. RemoveCloudISO: vm:%s transaction:%s", name, eventID)
	fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

	return true, nil
}

func (f *ServiceOrder) ConfigureDomain(name uuid.UUID, eventID uuid.UUID) (bool, error) {
	message := fmt.Sprintf("DEBUG: Event ServiceOrder. ConfigureDomain: vm:%s transaction:%s", name, eventID)
	fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

	return true, nil
}

func (f *ServiceOrder) RebootDomain(name uuid.UUID, eventID uuid.UUID) (bool, error) {
	message := fmt.Sprintf("DEBUG: Event ServiceOrder. RebootDomain: vm:%s transaction:%s", name, eventID)
	fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

	return true, nil
}

func (f *ServiceOrder) IsStartDomainTwo(name uuid.UUID, eventID uuid.UUID) (bool, error) {
	message := fmt.Sprintf("DEBUG: Event ServiceOrder. IsStartDomainTwo: vm:%s transaction:%s", name, eventID)
	fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

	return true, nil
}

func (f *ServiceOrder) Done(name uuid.UUID, eventID uuid.UUID) (bool, error) {
	message := fmt.Sprintf("DEBUG: Event ServiceOrder. Done: vm:%s transaction:%s", name, eventID)
	fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

	return true, nil
}

func (f *ServiceOrder) Error(name uuid.UUID, eventID uuid.UUID) (bool, error) {
	message := fmt.Sprintf("DEBUG: Event ServiceOrder. Error: vm:%s transaction:%s", name, eventID)
	fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

	return true, nil
}

func (f *ServiceOrder) Canceled(name uuid.UUID, eventID uuid.UUID) (bool, error) {
	message := fmt.Sprintf("DEBUG: Event ServiceOrder. Canceled: vm:%s transaction:%s", name, eventID)
	fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

	return true, nil
}

func (f *ServiceOrder) Reinstated(name uuid.UUID, eventID uuid.UUID) (bool, error) {
	message := fmt.Sprintf("DEBUG: Event ServiceOrder. Reinstated: vm:%s transaction:%s", name, eventID)
	fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

	return true, nil
}



func (f *ServiceOrder) CreateDisk(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. CreateDisk: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}


func (f *ServiceOrder) InitAttachDisk(name uuid.UUID, eventID uuid.UUID) (bool, error) {

        message := fmt.Sprintf("DEBUG: Event ServiceOrder. InitAttachDisk: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}


func (f *ServiceOrder) InitDeattachDisk(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. InitDeattachDisk: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}


func (f *ServiceOrder) AttachDisk(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. AttachDisk: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}


func (f *ServiceOrder) DeattachDisk(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. DeattachDisk: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}

func (f *ServiceOrder) InitAttachNetworkDevice(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. InitAttachNetworkDevice: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}


func (f *ServiceOrder) InitDeattachNetworkDevice(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. InitDeattachNetworkDevice: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}

func (f *ServiceOrder) AttachNetworkDevice(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. AttachNetworkDevice: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}


func (f *ServiceOrder) DeattachNetworkDevice(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. DeattachNetworkDevice: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}



func (f *ServiceOrder) InitDestroyDomain(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. InitDestroyDomain: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}

func (f *ServiceOrder) DestroyDomain(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. DestroyDomain: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}

func (f *ServiceOrder) InitSoftRebootDomain(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. InitSoftRebootDomain: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}

func (f *ServiceOrder) InitHardRebootDomain(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. InitHardRebootDomain: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}

func (f *ServiceOrder) InitShutdownDomain(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. InitShutdownDomain: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}

func (f *ServiceOrder) SoftRebootDomain(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. SoftRebootDomain: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}

func (f *ServiceOrder) HardRebootDomain(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. HardRebootDomain: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}

func (f *ServiceOrder) ShutdownDomain(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. ShutdownDomain: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}



func (f *ServiceOrder) InitMachinePause(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. InitMachinePause: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}


func (f *ServiceOrder) InitMachineResume(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. InitMachineResume: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}


func (f *ServiceOrder) InitMachineMigrate(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. InitMachineMigrate: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}


func (f *ServiceOrder) MachinePause(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. MachinePause: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}


func (f *ServiceOrder) MachineResume(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. MachineResume: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}

func (f *ServiceOrder) MachineMigrate(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. MachineMigrate: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}


func (f *ServiceOrder) StateReboot(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. StateReboot: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}


func (f *ServiceOrder) StateRunning(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. StateRunning: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}

func (f *ServiceOrder) StatePause(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. StatePause: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}

func (f *ServiceOrder) StateStop(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. StateStop: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}


func (f *ServiceOrder) StateError(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. StateError: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}

func (f *ServiceOrder) StateDestroy(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. StateDestroy: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}


func (f *ServiceOrder) InitStartDomain(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. InitStartDomain: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}

func (f *ServiceOrder) StartDomain(name uuid.UUID, eventID uuid.UUID) (bool, error) {
        message := fmt.Sprintf("DEBUG: Event ServiceOrder. StartDomain: vm:%s transaction:%s", name, eventID)
        fmt.Printf("DEBUG: %s\n", message)

        transaction := GetInstanceTransactionStore().GetFromStore(eventID)
        fmt.Printf("DEBUG: transaction:%v\n", transaction)

        domain := GetInstanceCloudDomainStore().GetFromStore(name)
        fmt.Printf("DEBUG: DOMAIN: %v\n", domain)

        return true, nil
}


/*********** PART 2 ***********/

type ServiceOrdersInterface interface {
	RunOrder(name string, args ...interface{}) (bool, error)
	RunOrderEvent(name string, args ...interface{}) []interface{}
	GetServiceOrder() map[string]AbstructMethod
}
type ServiceOrders struct {
	abstructMethods map[string]AbstructMethod
}

func (s *ServiceOrders) RunOrder(name string, args ...interface{}) (bool, error) {
	result := s.abstructMethods[name]

	argsReflect := make([]reflect.Value, 0)

	for _, v := range args {
		argsReflect = append(argsReflect, reflect.ValueOf(v))
	}
	val := result(argsReflect)

	value0 := val[0].Interface().(bool)
	var value1 error
	if val[1].Interface() != nil {
		value1 = val[1].Interface().(error)
	} else {
		value1 = nil
	}

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
		case bool:
			value := i.(bool)
			valueReturns = append(valueReturns, value)
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

func (s *ServiceOrders) GetServiceOrder() map[string]AbstructMethod {
	return s.abstructMethods
}

func (s *ServiceOrders) getServiceOrder(serviceOrder ServiceOrderInterface) {

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

func NewServiceOrders(serviceOrder ServiceOrderInterface) ServiceOrdersInterface {
	serviceOrders := ServiceOrders{}
	serviceOrders.getServiceOrder(serviceOrder)
	return &serviceOrders
}

/*********** PART 3 ***********/

type OrderEventInterface interface {
	String() string
	GetName() string
}

type OrderEvent struct {
	Name string
}

func NewOrderEvent(name string) OrderEventInterface {
	return &OrderEvent{Name: name}
}

func (f OrderEvent) String() string {
	return fmt.Sprintf("%s", f.Name)
}

func (f OrderEvent) GetName() string {
	return f.Name
}

/*********** PART 4 ***********/
type TransitionError struct {
	FromState OrderEventInterface
	ToState   OrderEventInterface
}

func (err TransitionError) Error() string {
	return fmt.Sprintf("invalid state transition from %v to %v", err.FromState, err.ToState)
}

type Transition struct {
	FromState OrderEventInterface `json:"from_state"`
	ToCancel  OrderEventInterface `json:"to_cancel"`
	ToState   OrderEventInterface `json:"to_state"`
	Timestamp *time.Time          `json:"timestamp"`
	Metadata  map[string]string   `json:"metadata"`
}

/*********** PART 5 ***********/

type FSMInterface interface {
	AddRule(fromState OrderEventInterface, toState OrderEventInterface, toCancel OrderEventInterface)
	GetMaxHistory() int
	GetRule(rule OrderEventInterface) Transition
	GetRules() map[string]Transition
	CurrentState(uuid uuid.UUID) OrderEventInterface
	CanTransition(uuid uuid.UUID, targetState OrderEventInterface) bool
	canTransition(fromState OrderEventInterface, toState OrderEventInterface) bool
	Transition(uuid uuid.UUID, eventId uuid.UUID, targetState OrderEventInterface, metadata map[string]string) (OrderEventInterface, error)
	AddToStore(storage StorageInterface)
	GetFromStore(uuid uuid.UUID) StorageInterface
}

type FSM struct {
	OrderStore *Store
	ruleset    map[string]Transition
	maxHistory int
}

func NewFSM(OrderStore *Store, maxHistory int) FSMInterface {
	return &FSM{
		OrderStore: OrderStore,
		ruleset:    make(map[string]Transition),
		maxHistory: maxHistory,
	}
}

func (o *FSM) AddToStore(storage StorageInterface) {
	(*o.OrderStore)[storage.GetUUID()] = storage
}

func (o *FSM) GetFromStore(uuid uuid.UUID) StorageInterface {
	return (*o.OrderStore)[uuid]
}

func (fsm *FSM) AddRule(fromState OrderEventInterface, toState OrderEventInterface, toCancel OrderEventInterface) {
	fsm.ruleset[fromState.String()] = Transition{FromState: fromState, ToCancel: toCancel, ToState: toState}
}

func (fsm *FSM) GetMaxHistory() int {
	return fsm.maxHistory
}

func (fsm *FSM) GetRules() map[string]Transition {
	return fsm.ruleset
}

func (fsm *FSM) GetRule(rule OrderEventInterface) Transition {
	return fsm.ruleset[rule.String()]
}

func (fsm *FSM) CurrentState(uuid uuid.UUID) OrderEventInterface {
	return (*fsm.OrderStore)[uuid].GetCurrentState()
}

func (fsm *FSM) CanTransition(uuid uuid.UUID, targetState OrderEventInterface) bool {
	currentState := (*fsm.OrderStore)[uuid].GetCurrentState()
	return fsm.canTransition(currentState, targetState)
}

func (fsm *FSM) canTransition(fromState OrderEventInterface, toState OrderEventInterface) bool {
	validTransitions, ok := fsm.ruleset[fromState.String()]
	if !ok {
		return false
	}

	if validTransitions.ToState.String() == toState.String() {
		return true
	}

	if validTransitions.ToCancel.String() == toState.String() {
		return true
	}
	return false
}

func (fsm *FSM) Transition(uuid uuid.UUID, eventId uuid.UUID, targetState OrderEventInterface, metadata map[string]string) (OrderEventInterface, error) {

	currentState := (*fsm.OrderStore)[uuid].GetCurrentState()

	if !fsm.canTransition(currentState, targetState) {
		return currentState, TransitionError{
			FromState: currentState,
			ToState:   targetState,
		}
	}

	/*	if fsm.maxHistory == 0 {
		transaction := (*fsm.OrderStore)[uuid]
		transaction.CurrentState = targetState
		return (*fsm.OrderStore)[uuid].CurrentState, nil
	}*/

	transaction := (*fsm.OrderStore)[uuid]

	tn := time.Now()
	transaction.SetTransitions(Transition{
		FromState: (*fsm.OrderStore)[uuid].GetCurrentState(),
		ToState:   targetState,
		Timestamp: &tn,
		Metadata:  metadata,
	})

	transaction = (*fsm.OrderStore)[uuid]
	transaction.SetCurrentState(targetState)

	return transaction.GetCurrentState(), nil
}

/*********** PART 6 ***********/

type StorageInterface interface {
	GetUUID() uuid.UUID
	SetUUID(uuid uuid.UUID)
	SetTransitions(transition Transition)
	GetTransitions() *[]Transition
	GetCurrentState() OrderEventInterface
	SetCurrentState(CurrentState OrderEventInterface)
}

type Storage struct {
	Uuid             uuid.UUID
	EventId		 uuid.UUID
	InitialState     OrderEventInterface
	CurrentState     OrderEventInterface
	TransitionsOrder *[]Transition
}

func (m *Storage) GetCurrentState() OrderEventInterface {
	return m.CurrentState
}

func (m *Storage) SetCurrentState(CurrentState OrderEventInterface) {
	m.CurrentState = CurrentState
}

func (m *Storage) GetUUID() uuid.UUID {
	return m.Uuid
}

func (m *Storage) GetEventId() uuid.UUID {
        return m.EventId
}


func (m *Storage) SetUUID(uuid uuid.UUID) {
	m.Uuid = uuid
}

func (m *Storage) SetTransitions(transition Transition) {
	(*m.TransitionsOrder) = append((*m.TransitionsOrder), transition)
}

func (m *Storage) GetTransitions() *[]Transition {
	return m.TransitionsOrder
}

func NewStorageElement(uuid uuid.UUID, eventId uuid.UUID, initialState OrderEventInterface, currentState OrderEventInterface) StorageInterface {
	transitionsOrder := []Transition{}
	return &Storage{Uuid: uuid, EventId: eventId, InitialState: initialState, CurrentState: currentState, TransitionsOrder: &transitionsOrder}
}

type Store map[uuid.UUID]StorageInterface

/*********** PART 7 ***********/

type OrderInterface interface {
	SetOrderStore(storage StorageInterface)
	RunEvents(uuid uuid.UUID, eventId uuid.UUID) (OrderEventInterface, error)
}

type Order struct {
	StatusDone    OrderEventInterface
	StatusError   OrderEventInterface
	State         FSMInterface
	ServiceOrders ServiceOrdersInterface
}

func (o *Order) SetOrderStore(storage StorageInterface) {
	o.State.AddToStore(storage)
}

func (o *Order) RunEvents(uuid uuid.UUID, eventId uuid.UUID) (OrderEventInterface, error) {
	fsm := o.State

	for i := 1; i <= fsm.GetMaxHistory(); i++ {

		transaction := fsm.GetFromStore(uuid)

		x := transaction.GetCurrentState()

		fmt.Printf("DEBUG, RunEvents, stage:%v\n", x.GetName())

		state, err := o.ServiceOrders.RunOrder(x.GetName(), uuid, eventId)
		fmt.Printf("DEBUG, RunEvents, stage exec:%v, %v\n", state, err)

		v := fsm.GetRule(x)
		var nextStep OrderEventInterface
		if state == true {
			nextStep = v.ToState
		} else {
			nextStep = v.ToCancel
		}
		if o.StatusDone.String() == transaction.GetCurrentState().String() || o.StatusError.String() == transaction.GetCurrentState().String() {
			fmt.Printf("DEBUG, RunEvents, stage: END: %s\n", transaction.GetCurrentState().String())
			break
		} else {
			if o.StatusDone == nextStep || o.StatusError == nextStep {
				break
			}

			canTransition := fsm.CanTransition(uuid, nextStep)
			fmt.Printf("DEBUG: Transition: =====> %v %v\n", nextStep, canTransition)
			if canTransition == true {
				_, err := fsm.Transition(uuid, eventId, nextStep, nil)
				if err != nil {
					fmt.Printf("DEBUG: Transition: %s, error: %v\n", x.GetName(), err)
				} else {
					fmt.Printf("DEBUG: Transition: %s successful. Current state: %v\n", x.GetName(), transaction.GetCurrentState())
				}
			}
			fmt.Println("DEBUG: -----------------------------")

		}
	}

	fmt.Println("DEBUG: -----------------------------")

	transaction := fsm.GetFromStore(uuid)
	fmt.Printf("Transition %s is successful. Current state: %v", uuid, transaction.GetCurrentState())
	return transaction.GetCurrentState(), nil
}

/*********** PART 8 ***********/

func NewOrderBus(matrix [][]string) OrderInterface {
	/*********** PART 9 ***********/

	var OrderStore Store

	OrderStore = make(Store, 0)

	serviceOrder := NewServiceOrder()
	s := NewServiceOrders(serviceOrder)

	orderEvent := make(map[string]OrderEventInterface, 0)
	for k, v := range s.GetServiceOrder() {
		fmt.Printf("DEBUG, init NewOrderEvent(%v:%v)\n", k, v)
		orderEvent[k] = NewOrderEvent(k)
	}

	order := &Order{State: NewFSM(&OrderStore, 20), ServiceOrders: s, StatusDone: orderEvent["Done"], StatusError: orderEvent["Error"]}

	/*********** PART 10 ***********/

	for _, v := range matrix {
		fmt.Printf("DEBUG, AddRule: %v\n", v)
		order.State.AddRule(orderEvent[v[0]], orderEvent[v[1]], orderEvent[v[2]])
	}

	fmt.Printf("%#v\n", order.State.GetRules())

	return order
}

/*********** PART 11 ***********/

func InitNewOrderBus() OrderInterface {

	matrix := [][]string{
		[]string{"InitDomain", "CreateBootDisk", "Canceled"},
                []string{"InitAttachDisk", "AttachDisk", "Error"},
                []string{"InitDeattachDisk", "DeattachDisk", "Error"},
                []string{"InitAttachNetworkDevice", "AttachNetworkDevice", "Error"},
                []string{"InitDeattachNetworkDevice", "DeattachNetworkDevice", "Error"},
                []string{"InitDestroyDomain", "DestroyDomain", "Error"},
                []string{"InitSoftRebootDomain", "SoftRebootDomain", "Error"},
                []string{"InitHardRebootDomain", "HardRebootDomain", "Error"},

                []string{"InitStartDomain", "StartDomain", "Error"},
                []string{"StartDomain", "StateRunning", "Error"},

                []string{"InitShutdownDomain", "ShutdownDomain", "Error"},
                []string{"InitMachinePause", "MachinePause", "StateError"},
                []string{"InitMachineResume", "MachineResume", "StateError"},
                []string{"InitMachineMigrate", "MachineMigrate", "StateError"},

		[]string{"CreateBootDisk", "CreateUserData", "Canceled"},

		[]string{"CreateUserData", "CreateNetworkDate", "Canceled"},
		[]string{"CreateNetworkDate", "FirstStartDomain", "Canceled"},

		[]string{"FirstStartDomain", "IsStopDomainOne", "Canceled"},
		[]string{"IsStopDomainOne", "StartDomainOne", "Error"},
		[]string{"StartDomainOne", "IsStartDomainOne", "Error"},
		[]string{"IsStartDomainOne", "RemoveCloudISO", "Error"},
		[]string{"RemoveCloudISO", "ConfigureDomain", "Canceled"},
		[]string{"ConfigureDomain", "RebootDomain", "Canceled"},
		[]string{"RebootDomain", "IsStartDomainTwo", "Canceled"},
		[]string{"IsStartDomainTwo", "StateRunning", "Error"},

                []string{"CreateDisk", "AttachDisk", "Error"},
                []string{"AttachDisk", "StateRunning", "Error"},
                []string{"DeattachDisk", "StateRunning", "Error"},


                []string{"AttachNetworkDevice", "StateRunning", "Error"},
                []string{"DeattachNetworkDevice", "StateRunning", "Error"},



                []string{"DestroyDomain", "StateDestroy", "Error"},
                []string{"SoftRebootDomain", "StateReboot", "Error"},
                []string{"HardRebootDomain", "StateReboot", "Error"},
                []string{"ShutdownDomain", "StateStop", "StateError"},



                []string{"MachinePause", "StateStop", "Error"},
                []string{"MachineResume", "StateStop", "Error"},
                []string{"MachineMigrate", "StateRunning", "Error"},



                []string{"Done", "Error", "Error"},
                []string{"Error", "Error", "Error"},
                []string{"Canceled", "Error", "Error"},

                []string{"Reinstated", "InitDomain", "Canceled"},

                []string{"StateReboot", "StateRunning", "Error"},
                []string{"StateDestroy", "Done", "Error"},
                []string{"StateRunning", "Done", "Error"},
                []string{"StatePause", "Done", "Error"},
                []string{"StateStop", "Done", "Error"},
                []string{"StateError", "Done", "Error"},
}

	order := NewOrderBus(matrix)

	return order

}


/*********** PART 12 ***********/

func RunEventBus(transaction *TransactionOrder, order OrderInterface) {


        GetInstanceTransactionStore().AddToStore(transaction)
	fmt.Printf("DEBUG: CloudDomainStore(): %v\n", GetInstanceCloudDomainStore().GetFromStore(transaction.OrderUUID))

        fmt.Printf("DEBUG: UUID EVENT: %v", transaction.Uuid.String())

        storage := NewStorageElement(transaction.OrderUUID, transaction.Uuid, &OrderEvent{Name: transaction.NameOrder}, &OrderEvent{Name: transaction.NameOrder})
        order.SetOrderStore(storage)

        a, b := order.RunEvents(transaction.OrderUUID, transaction.Uuid)
        fmt.Printf("DEBUG: VARS: %#v %#v\n", a, b)

        fmt.Println("DEBUG: Transitions:", storage.GetTransitions())
        for k, v := range *storage.GetTransitions() {
                fmt.Printf("DEBUG: %v:%v\n", k, v)
        }

	fmt.Printf("================================================================================\n")
}

/*********** PART 13 ***********/

var muTransactionStore sync.Mutex
var _transactionStores *TransactionStore

func GetInstanceTransactionStore() *TransactionStore {
    muTransactionStore.Lock()                    // <--- Unnecessary locking if instance already created
    defer muTransactionStore.Unlock()

    if _transactionStores == nil {
        _transactionStores = &TransactionStore{}
    }
    return _transactionStores
}

/*********** PART 13 ***********/

var muCloudDomainStoreByName sync.Mutex
var _cloudDomainStoreByName *CloudDomainStoreByName

func GetInstanceCloudDomainStoreByName() *CloudDomainStoreByName {
    muCloudDomainStoreByName.Lock()                    // <--- Unnecessary locking if instance already created
    defer muCloudDomainStoreByName.Unlock()

    if _cloudDomainStoreByName == nil {
        _cloudDomainStoreByName = &CloudDomainStoreByName{}
    }
    return _cloudDomainStoreByName
}


/*********** PART 13 ***********/

var muCloudDomain sync.Mutex
var _cloudDomainStores *CloudDomainStore

func GetInstanceCloudDomainStore() *CloudDomainStore {
        muCloudDomain.Lock()
        defer muCloudDomain.Unlock()

        if _cloudDomainStores == nil {
                _cloudDomainStores = &CloudDomainStore{}
        }
        return _cloudDomainStores
}

/*********** PART 14 ***********/



//==================================================================================

/*********** PART 0 ***********/

type ComputeNode struct{
        UUID            uuid.UUID
        Name            string
        IPV4Address     net.IP
}


func (o *ComputeNode) GetUUID() uuid.UUID {
        return o.UUID
}


func (o *ComputeNode) GetName() string {
        return o.Name
}

func (o *ComputeNode) GetIPV4Address() net.IP {
        return o.IPV4Address
}

/*********** PART 0 ***********/

type ComputeNodeStore map[uuid.UUID]ComputeNode

func (o *ComputeNodeStore) AddToStore(computeNode *ComputeNode) {
        uuid := computeNode.GetUUID()
        (*o)[uuid] = *computeNode
}

func (o *ComputeNodeStore) GetFromStore(uuid uuid.UUID) ComputeNode {
        return (*o)[uuid]
}



/*********** PART 0 ***********/

type ComputeNodeStoreByName map[string]uuid.UUID

func (o *ComputeNodeStoreByName) AddToStore(compute *ComputeNode) {
        (*o)[(*compute).GetName()] = (*compute).GetUUID()
}

func (o *ComputeNodeStoreByName) GetFromStore(compute string) uuid.UUID {
        return (*o)[compute]
}




/*********** PART 13 ***********/

var muComputeNodeStore sync.Mutex
var _computeNodeStoreStores *ComputeNodeStore

func GetInstanceComputeNodeStore() *ComputeNodeStore {
        muComputeNodeStore.Lock()                    // <--- Unnecessary locking if instance already created
        defer muComputeNodeStore.Unlock()

        if _computeNodeStoreStores == nil {
                _computeNodeStoreStores = &ComputeNodeStore{}
        }
        return _computeNodeStoreStores
}



/*********** PART 13 ***********/

var muComputeNodeStoreByName sync.Mutex
var _computeNodeStoreByName *ComputeNodeStoreByName

func GetInstanceComputeNodeStoreByName() *ComputeNodeStoreByName {
        muComputeNodeStoreByName.Lock()                    // <--- Unnecessary locking if instance already created
        defer muComputeNodeStoreByName.Unlock()

        if _computeNodeStoreByName == nil {
                _computeNodeStoreByName = &ComputeNodeStoreByName{}
        }
        return _computeNodeStoreByName
}




//==================================================================================





/*********** PART 0 ***********/

type ComputeNetwork struct{
        UUID            uuid.UUID
        Name            string

        IPV4Network     string
        IPV4Gateway     string

        IPV6Network     string
        IPV6Gateway     string

        IPV4DNS         []string
        IPV6DNS         []string
}


func (o *ComputeNetwork) GetUUID() uuid.UUID {
        return o.UUID
}


func (o *ComputeNetwork) GetName() string {
        return o.Name
}

/*********** PART 0 ***********/

type ComputeNetworkStore map[uuid.UUID]ComputeNetwork

func (o *ComputeNetworkStore) AddToStore(computeNode *ComputeNetwork) {
        uuid := computeNode.GetUUID()
        (*o)[uuid] = *computeNode
}

func (o *ComputeNetworkStore) GetFromStore(uuid uuid.UUID) ComputeNetwork {
        return (*o)[uuid]
}



/*********** PART 13 ***********/

var muComputeNetworkStore sync.Mutex
var _computeNetworkStore *ComputeNetworkStore

func GetInstanceComputeNetworkStoreStore() *ComputeNetworkStore {
        muComputeNetworkStore.Lock()                    // <--- Unnecessary locking if instance already created
        defer muComputeNetworkStore.Unlock()

        if _computeNetworkStore == nil {
                _computeNetworkStore = &ComputeNetworkStore{}
        }
        return _computeNetworkStore
}

//==================================================================================


func main() {


	computeUUID := uuid.New()
        computeUUID2 := uuid.New()

	networkUUID := uuid.New()

	computeNode := ComputeNode { UUID: computeUUID,  Name: "node1",  IPV4Address: net.ParseIP("192.168.1.10") }
	GetInstanceComputeNodeStore().AddToStore(&computeNode)
	GetInstanceComputeNodeStoreByName().AddToStore(&computeNode)


        computeNode2 := ComputeNode { UUID: computeUUID2,  Name: "node2",  IPV4Address: net.ParseIP("192.168.1.20") }
        GetInstanceComputeNodeStore().AddToStore(&computeNode2)
        GetInstanceComputeNodeStoreByName().AddToStore(&computeNode2)


	computeNetwork := ComputeNetwork{ UUID: networkUUID, Name: "switch1", IPV4Network: "192.168.200.0/24", IPV4Gateway: "192.168.200.1", IPV4DNS: []string{"192.168.1.10"}}
	GetInstanceComputeNetworkStoreStore().AddToStore(&computeNetwork)


	/*********** PART 15 ***********/

	order := InitNewOrderBus()

	/*********** PART 16 ***********/

	id := uuid.New()



	domain := CloudDomain{ Domain: "VMName", UUID: id, ComputeNodeUUID: computeUUID, NetworkUUID: networkUUID, InitOrder: time.Now()}
	GetInstanceCloudDomainStore().AddToStore( &domain )
	GetInstanceCloudDomainStoreByName().AddToStore( &domain )
	GetInstanceCloudDomainStore().GetFromStore(id).LastOrderInit = time.Now()



        fmt.Printf("#########################################################\n")

        for k,v := range *GetInstanceTransactionStore() {
                fmt.Printf("_transactionStores: %v: %#v\n", k, v)
        }

        for k,v := range *_cloudDomainStoreByName {
                fmt.Printf("_cloudDomainStoreByName %v: %v\n", k, v)
        }

        for k,v := range *_cloudDomainStores {
                fmt.Printf("_cloudDomainStores %v: %v\n", k, v)
        }


        for k,v := range *_computeNodeStoreStores {
                fmt.Printf("_cloudDomainStoreByName %v: %v\n", k, v)
        }


        for k,v := range *_computeNodeStoreByName {
                fmt.Printf("_cloudDomainStoreByName %v: %v\n", k, v)
        }


        for k,v := range *_computeNetworkStore {
                fmt.Printf("_cloudDomainStoreByName %v: %v\n", k, v)
        }

        fmt.Printf("#########################################################\n")


	eventId := uuid.New()
        transactions := TransactionOrder{Uuid: eventId, OrderUUID: id, XMLDomainconfig: "<xml config...............", NameOrder: "InitDomain", TimeOrder: time.Now() }
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderInit = time.Now()
	GetInstanceCloudDomainStore().GetFromStore(id).LastTransaction = eventId
	GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Time{}
	RunEventBus(&transactions, order)
	GetInstanceCloudDomainStore().GetFromStore(id).XMLDomainconfig = transactions.XMLDomainconfig
	GetInstanceCloudDomainStore().GetFromStore(id).Transactions = append(GetInstanceCloudDomainStore().GetFromStore(id).Transactions, eventId)
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Now()

        eventId = uuid.New()
	transactions = TransactionOrder{Uuid: eventId, OrderUUID: id,  Device: "sdb", Path: "/..../sdb.qcow2", NameOrder: "InitAttachDisk", TimeOrder: time.Now() }
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderInit = time.Now()
        GetInstanceCloudDomainStore().GetFromStore(id).LastTransaction = eventId
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Time{}
        RunEventBus(&transactions, order)
        GetInstanceCloudDomainStore().GetFromStore(id).Transactions = append(GetInstanceCloudDomainStore().GetFromStore(id).Transactions, eventId)
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Now()

        eventId = uuid.New()
        transactions = TransactionOrder{Uuid: eventId, OrderUUID: id,  Device: "sdb", Path: "/..../sdb.qcow2" , NameOrder: "InitDeattachDisk", TimeOrder: time.Now() }
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderInit = time.Now()
        GetInstanceCloudDomainStore().GetFromStore(id).LastTransaction = eventId
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Time{}
        RunEventBus(&transactions, order)
        GetInstanceCloudDomainStore().GetFromStore(id).Transactions = append(GetInstanceCloudDomainStore().GetFromStore(id).Transactions, eventId)
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Now()

        eventId = uuid.New()
        transactions = TransactionOrder{Uuid: eventId, OrderUUID: id,  Device: "enps......", Path: "network path......" , NameOrder: "InitAttachNetworkDevice", TimeOrder: time.Now()}
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderInit = time.Now()
        GetInstanceCloudDomainStore().GetFromStore(id).LastTransaction = eventId
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Time{}
        RunEventBus(&transactions, order)
        GetInstanceCloudDomainStore().GetFromStore(id).Transactions = append(GetInstanceCloudDomainStore().GetFromStore(id).Transactions, eventId)
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Now()

        eventId = uuid.New()
        transactions = TransactionOrder{Uuid: eventId, OrderUUID: id,  Device: "enps......", Path: "network path......" , NameOrder: "InitDeattachNetworkDevice", TimeOrder: time.Now()}
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderInit = time.Now()
        GetInstanceCloudDomainStore().GetFromStore(id).LastTransaction = eventId
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Time{}
        RunEventBus(&transactions, order)
        GetInstanceCloudDomainStore().GetFromStore(id).Transactions = append(GetInstanceCloudDomainStore().GetFromStore(id).Transactions, eventId)
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Now()

        eventId = uuid.New()
        transactions = TransactionOrder{Uuid: eventId, OrderUUID: id, MigrateTo: computeUUID2 , NameOrder: "InitMachineMigrate", TimeOrder: time.Now()}
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderInit = time.Now()
        GetInstanceCloudDomainStore().GetFromStore(id).LastTransaction = eventId
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Time{}
        RunEventBus(&transactions, order)
	GetInstanceCloudDomainStore().GetFromStore(id).ComputeNodeUUID = computeUUID2
        GetInstanceCloudDomainStore().GetFromStore(id).Transactions = append(GetInstanceCloudDomainStore().GetFromStore(id).Transactions, eventId)
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Now()

        eventId = uuid.New()
        transactions = TransactionOrder{Uuid: eventId, OrderUUID: id , NameOrder: "InitSoftRebootDomain", TimeOrder: time.Now() }
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderInit = time.Now()
        GetInstanceCloudDomainStore().GetFromStore(id).LastTransaction = eventId
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Time{}
        RunEventBus(&transactions, order)
        GetInstanceCloudDomainStore().GetFromStore(id).Transactions = append(GetInstanceCloudDomainStore().GetFromStore(id).Transactions, eventId)
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Now()

        eventId = uuid.New()
        transactions = TransactionOrder{Uuid: eventId, OrderUUID: id , NameOrder: "InitHardRebootDomain", TimeOrder: time.Now() }
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderInit = time.Now()
        GetInstanceCloudDomainStore().GetFromStore(id).LastTransaction = eventId
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Time{}
        RunEventBus(&transactions, order)
        GetInstanceCloudDomainStore().GetFromStore(id).Transactions = append(GetInstanceCloudDomainStore().GetFromStore(id).Transactions, eventId)
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Now()

        eventId = uuid.New()
        transactions = TransactionOrder{Uuid: eventId, OrderUUID: id , NameOrder: "InitShutdownDomain", TimeOrder: time.Now() }
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderInit = time.Now()
        GetInstanceCloudDomainStore().GetFromStore(id).LastTransaction = eventId
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Time{}
        RunEventBus(&transactions, order)
        GetInstanceCloudDomainStore().GetFromStore(id).Transactions = append(GetInstanceCloudDomainStore().GetFromStore(id).Transactions, eventId)
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Now()

        eventId = uuid.New()
        transactions = TransactionOrder{Uuid: eventId, OrderUUID: id , NameOrder: "InitStartDomain", TimeOrder: time.Now() }
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderInit = time.Now()
        GetInstanceCloudDomainStore().GetFromStore(id).LastTransaction = eventId
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Time{}
        RunEventBus(&transactions, order)
        GetInstanceCloudDomainStore().GetFromStore(id).Transactions = append(GetInstanceCloudDomainStore().GetFromStore(id).Transactions, eventId)
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Now()

        eventId = uuid.New()
        transactions = TransactionOrder{Uuid: eventId, OrderUUID: id , NameOrder: "InitDestroyDomain", TimeOrder: time.Now() }
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderInit = time.Now()
        GetInstanceCloudDomainStore().GetFromStore(id).LastTransaction = eventId
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Time{}
        RunEventBus(&transactions, order)
        GetInstanceCloudDomainStore().GetFromStore(id).Transactions = append(GetInstanceCloudDomainStore().GetFromStore(id).Transactions, eventId)
        GetInstanceCloudDomainStore().GetFromStore(id).LastOrderDone = time.Now()


	fmt.Printf("#########################################################\n")

	for k,v := range *GetInstanceTransactionStore() {
		fmt.Printf("_transactionStores: %v: %#v\n", k, v)
	}

        for k,v := range *_cloudDomainStoreByName {
                fmt.Printf("_cloudDomainStoreByName %v: %v\n", k, v)
        }

        for k,v := range *_cloudDomainStores {
                fmt.Printf("_cloudDomainStores %v: %v\n", k, v)
        }


        for k,v := range *_computeNodeStoreStores {
                fmt.Printf("_cloudDomainStoreByName %v: %v\n", k, v)
        }


        for k,v := range *_computeNodeStoreByName {
                fmt.Printf("_cloudDomainStoreByName %v: %v\n", k, v)
        }


        for k,v := range *_computeNetworkStore {
                fmt.Printf("_cloudDomainStoreByName %v: %v\n", k, v)
        }

        fmt.Printf("#########################################################\n")



        fmt.Printf("#########################################################\n")
        fmt.Printf("#########################################################\n")

	yamlData, err := yaml.Marshal(GetInstanceTransactionStore())
	if err != nil {
		fmt.Printf("Error while Marshaling. %v", err)
	}
	fmt.Println(" --- YAML ---")
	fmt.Println(string(yamlData))  // yamlData will be in bytes. So converting it to string.

        fmt.Printf("#########################################################\n")
        fmt.Printf("#########################################################\n")

        yamlData, err = yaml.Marshal(_cloudDomainStoreByName)
        if err != nil {
                fmt.Printf("Error while Marshaling. %v", err)
        }
        fmt.Println(" --- YAML ---")
        fmt.Println(string(yamlData))  // yamlData will be in bytes. So converting it to string.

        fmt.Printf("#########################################################\n")
        fmt.Printf("#########################################################\n")

        yamlData, err = yaml.Marshal(_cloudDomainStores)
        if err != nil {
                fmt.Printf("Error while Marshaling. %v", err)
        }
        fmt.Println(" --- YAML ---")
        fmt.Println(string(yamlData))  // yamlData will be in bytes. So converting it to string.

        fmt.Printf("#########################################################\n")
        fmt.Printf("#########################################################\n")

        yamlData, err = yaml.Marshal(_computeNodeStoreStores)
        if err != nil {
                fmt.Printf("Error while Marshaling. %v", err)
        }
        fmt.Println(" --- YAML ---")
        fmt.Println(string(yamlData))  // yamlData will be in bytes. So converting it to string.



        fmt.Printf("#########################################################\n")
        fmt.Printf("#########################################################\n")

        yamlData, err = yaml.Marshal(_computeNodeStoreByName)
        if err != nil {
                fmt.Printf("Error while Marshaling. %v", err)
        }
        fmt.Println(" --- YAML ---")
        fmt.Println(string(yamlData))  // yamlData will be in bytes. So converting it to string.

        fmt.Printf("#########################################################\n")
        fmt.Printf("#########################################################\n")

        yamlData, err = yaml.Marshal(_computeNetworkStore)
        if err != nil {
                fmt.Printf("Error while Marshaling. %v", err)
        }
        fmt.Println(" --- YAML ---")
        fmt.Println(string(yamlData))  // yamlData will be in bytes. So converting it to string.



}