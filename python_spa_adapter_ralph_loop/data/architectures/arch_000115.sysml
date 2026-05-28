package arch_000115 {

    // Docking Mechanism Reference Architecture 115
    // Domain: docking mechanism

    // Requirements
    public requirement REQ_001 {
        doc "The docking mechanism system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The docking mechanism system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The docking mechanism system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The docking mechanism system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def NavPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdIn;
    }

    public part def CommPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdIn;
    }

    public part def FlightActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
    }

    public part def ControlComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn;
        port pwrIn;
        port cmdOut;
    }

    public part def DataSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port statusOut;
    }

    public part def PowerActuator {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port telemetryOut;
    }

    public part def MonitorSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut;
        port configIn;
        port dataIn;
    }

    // System Definition
    public part def DockingMechanismSystem {
        part navpayload : NavPayload {
            satisfy REQ_004;
        }
        part commpayload : CommPayload {
            satisfy REQ_002;
        }
        part flightactuator : FlightActuator {
            satisfy REQ_001;
        }
        part controlcomputer : ControlComputer {
        }
        part datasensor : DataSensor {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part poweractuator : PowerActuator {
        }
        part monitorsensor : MonitorSensor {
        }

        // Connections
        connect navpayload.cmdIn to commpayload.cmdIn;
        connect datasensor.statusOut to commpayload.cmdIn;
        connect monitorsensor.telemetryOut to commpayload.cmdIn;
        connect poweractuator.telemetryOut to flightactuator.dataIn;
    }

    // System Instance
    part dockingmechanismsystem : DockingMechanismSystem;

}