package arch_000178 {

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

    // Component Definitions
    public part def DataController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut;
        port dataOut;
    }

    public part def MissionSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port cmdIn;
        port sensorOut;
    }

    public part def MissionComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut;
        port telemetryOut;
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
    part sensorsuitesystem : SensorSuiteSystem;

}