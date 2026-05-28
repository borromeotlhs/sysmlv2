package arch_000187 {

    // Avionics Bay Reference Architecture 187
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

    // Component Definitions
    public part def NavInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
    }

    public part def NavProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut;
        port sensorOut;
        port pwrIn;
    }

    public part def ControlUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port ctrlIn;
    }

    // System Definition
    public part def AvionicsBaySystem {
        part navinterface : NavInterface {
        }
        part navprocessor : NavProcessor {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part controlunit : ControlUnit {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect navinterface.telemetryOut to navprocessor.sensorOut;
        connect controlunit.ctrlIn to navprocessor.pwrOut;
        connect navinterface.telemetryOut to navprocessor.pwrOut;
        connect controlunit.ctrlIn to navprocessor.pwrIn;
        connect navinterface.telemetryOut to controlunit.telemetryOut;
    }

    // System Instance
    part avionicsbaysystem : AvionicsBaySystem;

}