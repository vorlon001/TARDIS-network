import random

class VM:

    def STARTING_INIT_VM(self,text):
        print("STARTING_INIT_VM")
        return (True, text)

    def VMSTOP(self,text):
        print("VMSTOP")
        return (True, text)

    def VMREMOVE(self,text):
        print("VMREMOVE")
        return (True, text)

    def VMRUNNING(self,text):
        print("VMRUNNING")
        return (True, text)

    def VMSHUTDOWN(self,text):
        print("VMSHUTDOWN")
        return (True, text)

    def TASK_INITVM(self,text):
        print("TASK_INITVM")
        return (True, text)

    def TASK_DELETED_VM(self,text):
        print("TASK_DELETED_VM")
        return (True, text)

    def VM_SYSTEM_ALERT(self,text):
        print("VM_SYSTEM_ALERT")
        return (True, text)

    def ERROR_STATE_STOP(self,text):
        print("ERROR_STATE_STOP")
        return (True, text)

    def START(self,txt):
        print("STARTING_INIT_VM",txt)
        if txt == "CONFIG":
            newState = True
        else:
            newState = False
        return (newState, txt)

    def VM_CREATE_CONFIG(self,txt):
        print("VM_CREATE_CONFIG",txt)
        if txt == "CONFIG":
            newState = True
        else:
            newState = False
        return (newState, txt)

    def VM_INITVM(self,txt):
        print("VM_INITVM",txt)
        if txt == "CONFIG":
            newState = True
        else:
            newState = False
        return (newState, txt)

    def VM_REINIT(self,txt):
        print("VM_REINIT",txt)
        newState = True
        return (newState, txt)

    def VM_START_PENDING(self,txt):
        print("VM_START_PENDING",txt)
        delta = random.randint(0, 100)
        if delta > 50:
            print("ERROR: VM_START_PENDING")
            newState = False
        elif txt == "CONFIG":
            newState = True
        else:
            newState = False
        return (newState, txt)

    def VM_SETUP_PENDING(self,txt):
        print("VM_SETUP_PENDING",txt)
        delta = random.randint(0, 100)
        if delta > 50:
            print("ERROR: VM_SETUP_PENDING")
            newState = False
        elif txt == "CONFIG":
            newState = True
        else:
            newState = False
        return (newState, txt)

    def VM_SHUTDOWN_PENDING(self,txt):
        print("VM_SHUTDOWN_PENDING",txt)
        delta = random.randint(0, 100)
        if delta > 50:
            print("ERROR: VM_SHUTDOWN_PENDING")
            newState = False
        elif txt == "CONFIG":
            newState = True
        else:
            newState = False
        return (newState, txt)

    def VM_DELETION_PENDING(self,txt):
        print("VM_DELETION_PENDING",txt)
        if txt == "CONFIG":
            newState = True
        else:
            newState = False
        return (newState, txt)

    def VM_DELETED(self,txt):
        print("VM_DELETED",txt)
        if txt == "CONFIG":
            newState = True
        else:
            newState = False
        return (newState, txt)
    def VM_READY(self,txt):
        print("VM_READY",txt)
        if txt == "CONFIG":
            newState = True
        else:
            newState = False
        return (newState, txt)


    def GET_MODEL(self):
        return {
                "START":                 self.START,
                "CREATE_CONFIG":         self.VM_CREATE_CONFIG,
                "INITVM":                self.VM_INITVM,
                "REINIT":                self.VM_REINIT,
                "START_PENDING":         self.VM_START_PENDING,
                "SETUP_PENDING":         self.VM_SETUP_PENDING,
                "SHUTDOWN_PENDING":      self.VM_SHUTDOWN_PENDING,
                "DELETION_PENDING":      self.VM_DELETION_PENDING,
                "DELETED":               self.VM_DELETED,
                "READY":                 self.VM_READY,
                "STARTING_INIT_VM":	 self.STARTING_INIT_VM,
                "STOP":			 self.VMSTOP,
		"SHUTDOWN":		 self.VMSHUTDOWN,
                "REMOVE":		 self.VMREMOVE,
		"RUNNING":		 self.VMRUNNING,
                "TASK_INITVM":		 self.TASK_INITVM,
                "TASK_DELETED_VM":       self.TASK_DELETED_VM,
		"ERROR_STATE_STOP":	 self.ERROR_STATE_STOP,
		"SYSTEM_ALERT":		 self.VM_SYSTEM_ALERT
                }
