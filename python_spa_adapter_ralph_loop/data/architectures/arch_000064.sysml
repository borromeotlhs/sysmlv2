package arch_000064 {

    import ScalarValues::*;

    // Uav Payload Reference Architecture 64
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

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def PowerIF;
    public port def StatusIF;

    // Component Definitions
    public part def MissionModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : PowerIF;
        port dataIn : CommandIF;
    }

    public part def MissionPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut : StatusIF;
        port dataOut : ControlIF;
        port dataOut : StatusIF;
    }

    // System Definition
    public part def UavPayloadSystem {
        part missionmodule : MissionModule {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part missionpayload : MissionPayload {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_004;
        }

        // Connections
        connect missionpayload.telemetryOut to missionmodule.statusOut;
        connect missionpayload.dataOut to missionmodule.statusOut;
        connect missionmodule.dataIn to missionpayload.dataOut;
        connect missionpayload.telemetryOut to missionmodule.dataIn;
    }

    // System Instance
    public part uavpayloadsystem : UavPayloadSystem;

}