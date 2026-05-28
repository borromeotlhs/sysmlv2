package arch_000065 {

    // Uav Payload Reference Architecture 65
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
    public part def SensorAssembly {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut;
    }

    public part def MonitorBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
        port dataOut;
        port dataOut;
    }

    public part def MissionAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
        port pwrIn;
    }

    // System Definition
    public part def UavPayloadSystem {
        part sensorassembly : SensorAssembly {
            satisfy REQ_004;
        }
        part monitorbus : MonitorBus {
        }
        part missionassembly : MissionAssembly {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
            satisfy REQ_004;
        }

        // Connections
        connect monitorbus.pwrIn to missionassembly.cmdIn;
        connect missionassembly.pwrIn to monitorbus.dataOut;
    }

    // System Instance
    part uavpayloadsystem : UavPayloadSystem;

}