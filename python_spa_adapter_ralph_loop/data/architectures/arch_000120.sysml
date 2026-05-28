package arch_000120 {

    // Avionics Bay Reference Architecture 120
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
    public part def NavController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
        port telemetryOut;
    }

    public part def NavUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port cmdIn;
    }

    public part def MonitorInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
        port ctrlIn;
    }

    public part def ProcessingPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn;
    }

    public part def NavModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port sensorOut;
        port statusOut;
    }

    public part def DataProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut;
        port pwrIn;
    }

    public part def ControlUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
        port statusOut;
    }

    // System Definition
    public part def AvionicsBaySystem {
        part navcontroller : NavController {
        }
        part navunit : NavUnit {
            satisfy REQ_002;
        }
        part monitorinterface : MonitorInterface {
            satisfy REQ_001;
        }
        part processingpayload : ProcessingPayload {
        }
        part navmodule : NavModule {
            satisfy REQ_001;
        }
        part dataprocessor : DataProcessor {
            satisfy REQ_003;
        }
        part controlunit : ControlUnit {
        }

        // Connections
        connect navmodule.sensorOut to navunit.ctrlIn;
        connect processingpayload.pwrIn to navcontroller.telemetryOut;
        connect navunit.cmdIn to controlunit.statusOut;
    }

    // System Instance
    part avionicsbaysystem : AvionicsBaySystem;

}