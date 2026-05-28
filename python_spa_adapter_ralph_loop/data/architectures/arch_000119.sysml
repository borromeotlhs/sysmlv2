package arch_000119 {

    // Thruster Assembly Reference Architecture 119
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
    public part def MonitorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut;
        port sensorOut;
        port sensorOut;
    }

    public part def PowerProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn;
        port configIn;
    }

    public part def CommandUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port cmdOut;
    }

    public part def FlightComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut;
        port ctrlIn;
        port dataIn;
    }

    public part def ControlSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut;
        port cmdOut;
    }

    // System Definition
    public part def ThrusterAssemblySystem {
        part monitorcontroller : MonitorController {
            satisfy REQ_004;
        }
        part powerprocessor : PowerProcessor {
            satisfy REQ_002;
        }
        part commandunit : CommandUnit {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part flightcomputer : FlightComputer {
            satisfy REQ_003;
        }
        part controlsensor : ControlSensor {
            satisfy REQ_001;
        }

        // Connections
        connect monitorcontroller.sensorOut to flightcomputer.pwrOut;
        connect monitorcontroller.sensorOut to controlsensor.telemetryOut;
    }

    // System Instance
    part thrusterassemblysystem : ThrusterAssemblySystem;

}