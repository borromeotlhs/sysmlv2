package arch_000053 {

    import ScalarValues::*;

    // Communication Relay Reference Architecture 53
    // Domain: communication relay

    // Requirements
    public requirement REQ_001 {
        doc "The communication relay system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The communication relay system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The communication relay system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def PowerSubsystem {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port ctrlIn : DiagnosticIF;
        port configIn : ThermalIF;
        port ctrlIn : DataIF;
    }

    public part def PowerPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn : CommandIF;
    }

    public part def DistributionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut : DiagnosticIF;
        port statusOut : ControlIF;
    }

    public part def ThermalUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : StatusIF;
        port telemetryOut : DiagnosticIF;
    }

    public part def DataBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : ControlIF;
    }

    // System Definition
    public part def CommunicationRelaySystem {
        part powersubsystem : PowerSubsystem {
        }
        part powerpayload : PowerPayload {
        }
        part distributioncontroller : DistributionController {
            satisfy REQ_001;
        }
        part thermalunit : ThermalUnit {
            satisfy REQ_001;
        }
        part databus : DataBus {
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect thermalunit.telemetryOut to distributioncontroller.statusOut;
        connect thermalunit.pwrOut to distributioncontroller.statusOut;
        connect thermalunit.telemetryOut to powerpayload.pwrIn;
    }

    // System Instance
    public part communicationrelaysystem : CommunicationRelaySystem;

}