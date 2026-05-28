package arch_000023 {

    // Avionics Bay Reference Architecture 23
    // Domain: avionics bay

    // Requirements
    public requirement REQ_001 {
        doc "The avionics bay system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The avionics bay system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The avionics bay system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The avionics bay system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def CommUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port configIn;
    }

    public part def MissionActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port telemetryOut;
        port telemetryOut;
    }

    public part def MonitorBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port configIn;
    }

    public part def ProcessingPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataIn;
        port pwrIn;
        port statusOut;
    }

    public part def PowerModule {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port dataIn;
    }

    public part def ControlAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut;
        port pwrIn;
    }

    public part def DataInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port pwrOut;
    }

    // System Definition
    public part def AvionicsBaySystem {
        part communit : CommUnit {
            satisfy REQ_002;
        }
        part missionactuator : MissionActuator {
        }
        part monitorbus : MonitorBus {
        }
        part processingpayload : ProcessingPayload {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part powermodule : PowerModule {
            satisfy REQ_001;
            satisfy REQ_004;
        }
        part controlassembly : ControlAssembly {
            satisfy REQ_002;
        }
        part datainterface : DataInterface {
        }

        // Connections
        connect datainterface.ctrlIn to missionactuator.telemetryOut;
        connect processingpayload.dataIn to datainterface.pwrOut;
        connect monitorbus.configIn to missionactuator.telemetryOut;
        connect communit.configIn to monitorbus.ctrlIn;
        connect missionactuator.telemetryOut to processingpayload.pwrIn;
    }

    // System Instance
    part avionicsbaysystem : AvionicsBaySystem;

}