import yaml
import VM
from pprint import pprint as dump


class obj(object):
    def __init__(self, d):
        for a, b in d.items():
            if isinstance(b, (list, tuple)):
               setattr(self, a, [obj(x) if isinstance(x, dict) else x for x in b])
            else:
               setattr(self, a, obj(b) if isinstance(b, dict) else b)

def loadConfig(filename):
    with open(filename, 'r') as f:
        doc = yaml.load(f)
    return doc


MODEL = loadConfig(filename='VM.yaml')

dump(MODEL)

ROBOT=globals()['VM'].__dict__['VM']
acriveROBOT=ROBOT()
modelROBOT=acriveROBOT.GET_MODEL()


MODELv2=obj(MODEL)

def runV2(TASK, config, LIMIT_ITRATOR, LIMIT_ITRATOR_STOP, MODELv2,modelROBOT):
    getStartMETHOD = lambda TASK: getattr(MODELv2.TASK,TASK).START.METHOD
    getInitOK = lambda METHOD:  getattr(MODELv2.INIT,METHOD).OK.METHOD
    getInitErr = lambda METHOD:  getattr(MODELv2.INIT,METHOD).ERR.METHOD
    getOkMETHOD = lambda METHOD,TASK: getattr(getattr(MODELv2.STAGE,METHOD).OK,TASK).METHOD
    getErrMETHOD = lambda METHOD:  getattr(MODELv2.STAGE,METHOD).ERR.METHOD
    configVM = config
    METHOD =  getStartMETHOD(TASK)
    status, configVM = modelROBOT[METHOD](configVM)
    METHOD = getInitOK(METHOD) if status else getInitErr(METHOD)
    ITERATION = 0
    while True:
        status, configVM = modelROBOT[METHOD](configVM)
        METHOD = getOkMETHOD(METHOD,TASK) if status else getErrMETHOD(METHOD)
        if METHOD  in MODEL['DONE']:
            break
        if METHOD in MODEL['EXCEPTION']:
            break
        if ITERATION < LIMIT_ITRATOR:
            ITERATION = ITERATION + 1
        elif ITERATION < LIMIT_ITRATOR_STOP:
            METHOD = "SHUTDOWN"
            ITERATION = ITERATION + 1
        else:
            print("LIMIT_ITRATOR_STOP")
            return False, None
    status, configVM = modelROBOT[METHOD](configVM)
    return status, configVM



LIMIT_ITRATOR=20
LIMIT_ITRATOR_STOP=40




TASK='INIT'
config="CONFIG"
modelROBOT=modelROBOT
runV2(TASK,config,LIMIT_ITRATOR,LIMIT_ITRATOR_STOP,MODELv2,modelROBOT)


TASK='STOP'
config="CONFIG"
modelROBOT=modelROBOT
runV2(TASK,config,LIMIT_ITRATOR,LIMIT_ITRATOR_STOP,MODELv2,modelROBOT)

TASK='DELETE'
config="CONFIG"
modelROBOT=modelROBOT
runV2(TASK,config,LIMIT_ITRATOR,LIMIT_ITRATOR_STOP,MODELv2,modelROBOT)
