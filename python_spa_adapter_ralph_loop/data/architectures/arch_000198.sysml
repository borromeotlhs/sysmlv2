package arch_000198 {

    // Autonomous Rover Reference Architecture 198
    // Domain: autonomous rover

    // Requirements
    public requirement REQ_001 {
        doc "The autonomous rover system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The autonomous rover system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The autonomous rover system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The autonomous rover system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def MonitorModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
        port dataIn;
    }

    public part def DataBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
    }

    public part def NavController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
        port pwrOut;
        port ctrlIn;
    }

    public part def FlightSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut;
        port statusOut;
    }

    public part def ControlAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
        port configIn;
        port dataIn;
    }

    public part def PowerBus {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port configIn;
    }

    // System Definition
    public part def AutonomousRoverSystem {
        part monitormodule : MonitorModule {
        }
        part databus : DataBus {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part navcontroller : NavController {
        }
        part flightsensor : FlightSensor {
            satisfy REQ_001;
        }
        part controlassembly : ControlAssembly {
            satisfy REQ_001;
            satisfy REQ_004;
        }
        part powerbus : PowerBus {
            satisfy REQ_002;
        }

        // Connections
        connect powerbus.configIn to flightsensor.cmdOut;
        connect controlassembly.cmdIn to monitormodule.dataIn;
        connect flightsensor.statusOut to controlassembly.cmdIn;
    }

    // System Instance
    part autonomousroversystem : AutonomousRoverSystem;

}