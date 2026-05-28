package arch_000165 {

    // Uav Payload Reference Architecture 165
    // Domain: uav payload

    // Requirements
    public requirement REQ_001 {
        doc "The uav payload system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The uav payload system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The uav payload system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The uav payload system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def ControlUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port configIn;
    }

    public part def MonitorProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn;
        port sensorOut;
    }

    public part def MissionComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
    }

    public part def NavUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
        port sensorOut;
    }

    public part def MonitorSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
        port sensorOut;
    }

    // System Definition
    public part def UavPayloadSystem {
        part controlunit : ControlUnit {
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part monitorprocessor : MonitorProcessor {
        }
        part missioncomputer : MissionComputer {
        }
        part navunit : NavUnit {
            satisfy REQ_003;
            satisfy REQ_004;
        }
        part monitorsubsystem : MonitorSubsystem {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect missioncomputer.pwrIn to monitorsubsystem.dataOut;
        connect monitorprocessor.sensorOut to navunit.cmdOut;
        connect monitorprocessor.sensorOut to monitorsubsystem.dataOut;
        connect navunit.cmdOut to controlunit.telemetryOut;
    }

    // System Instance
    part uavpayloadsystem : UavPayloadSystem;

}