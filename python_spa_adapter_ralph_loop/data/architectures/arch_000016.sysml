package arch_000016 {

    // Thruster Assembly Reference Architecture 16
    // Domain: thruster assembly

    // Requirements
    public requirement REQ_001 {
        doc "The thruster assembly system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The thruster assembly system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The thruster assembly system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The thruster assembly system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def ProcessingPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut;
    }

    public part def MonitorBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
    }

    public part def NavPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut;
        port pwrOut;
    }

    // System Definition
    public part def ThrusterAssemblySystem {
        part processingpayload : ProcessingPayload {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part monitorbus : MonitorBus {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part navpayload : NavPayload {
            satisfy REQ_001;
            satisfy REQ_004;
        }

        // Connections
        connect navpayload.telemetryOut to monitorbus.statusOut;
        connect processingpayload.cmdOut to monitorbus.statusOut;
        connect monitorbus.statusOut to navpayload.pwrOut;
    }

    // System Instance
    part thrusterassemblysystem : ThrusterAssemblySystem;

}