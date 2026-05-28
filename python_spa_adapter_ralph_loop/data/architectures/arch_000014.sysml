package arch_000014 {

    import ScalarValues::*;

    // Avionics Bay Reference Architecture 14
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

    // Port Definitions
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def ThermalIF;

    // Component Definitions
    public part def ControlProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : DataIF;
        port configIn : ThermalIF;
    }

    public part def DataProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn : ControlIF;
        port dataIn : DiagnosticIF;
    }

    // System Definition
    public part def AvionicsBaySystem {
        part controlprocessor : ControlProcessor {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part dataprocessor : DataProcessor {
            satisfy REQ_001;
            satisfy REQ_003;
        }

        // Connections
        connect controlprocessor.configIn to dataprocessor.pwrIn;
        connect controlprocessor.telemetryOut to dataprocessor.pwrIn;
    }

    // System Instance
    public part avionicsbaysystem : AvionicsBaySystem;

}