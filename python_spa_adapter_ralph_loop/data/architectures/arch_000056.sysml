package arch_000056 {

    import ScalarValues::*;

    // Reaction Wheel Reference Architecture 56
    // Domain: reaction wheel

    // Requirements
    public requirement REQ_001 {
        doc "The reaction wheel system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The reaction wheel system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The reaction wheel system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The reaction wheel system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def DataPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn : DataIF;
    }

    public part def ControlSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : ControlIF;
        port pwrOut : ThermalIF;
        port ctrlIn : DataIF;
    }

    public part def CommComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : TelemetryIF;
        port sensorOut : ControlIF;
    }

    public part def ProcessingModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : DiagnosticIF;
        port statusOut : DiagnosticIF;
        port cmdOut : ControlIF;
    }

    public part def DataUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : DiagnosticIF;
        port dataIn : SignalIF;
    }

    public part def DistributionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : DataIF;
        port telemetryOut : PowerIF;
        port pwrOut : DataIF;
    }

    // System Definition
    public part def ReactionWheelSystem {
        part datapayload : DataPayload {
        }
        part controlsubsystem : ControlSubsystem {
            satisfy REQ_001;
        }
        part commcomputer : CommComputer {
        }
        part processingmodule : ProcessingModule {
            satisfy REQ_001;
            satisfy REQ_004;
        }
        part dataunit : DataUnit {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part distributionbus : DistributionBus {
            satisfy REQ_002;
        }

        // Connections
        connect commcomputer.telemetryOut to controlsubsystem.dataIn;
        connect commcomputer.sensorOut to distributionbus.configIn;
        connect processingmodule.statusOut to dataunit.ctrlIn;
    }

    // System Instance
    public part reactionwheelsystem : ReactionWheelSystem;

}