package arch_000178 {

    import ScalarValues::*;

    // Sensor Suite Reference Architecture 178
    // Domain: sensor suite

    // Requirements
    public requirement REQ_001 {
        doc "The sensor suite system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The sensor suite system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The sensor suite system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def DataIF;
    public port def PowerIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def DataController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut : DataIF;
        port dataOut : DataIF;
    }

    public part def MissionSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : PowerIF;
        port cmdIn : StatusIF;
        port sensorOut : DataIF;
    }

    public part def MissionComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut : ConfigIF;
        port telemetryOut : ThermalIF;
    }

    // System Definition
    public part def SensorSuiteSystem {
        part datacontroller : DataController {
            satisfy REQ_001;
        }
        part missionsubsystem : MissionSubsystem {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part missioncomputer : MissionComputer {
            satisfy REQ_003;
        }

        // Connections
        connect missionsubsystem.cmdIn to datacontroller.dataOut;
        connect missionsubsystem.cmdIn to missioncomputer.pwrOut;
        connect missionsubsystem.dataIn to missioncomputer.pwrOut;
    }

    // System Instance
    public part sensorsuitesystem : SensorSuiteSystem;

}