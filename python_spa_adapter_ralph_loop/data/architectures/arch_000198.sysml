package arch_000198 {

    import ScalarValues::*;

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

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def MonitorModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : ConfigIF;
        port dataIn : CommandIF;
    }

    public part def DataBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : StatusIF;
    }

    public part def NavController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn : ConfigIF;
        port pwrOut : ControlIF;
        port ctrlIn : DataIF;
    }

    public part def FlightSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut : TelemetryIF;
        port statusOut : ConfigIF;
    }

    public part def ControlAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn : PowerIF;
        port configIn : SignalIF;
        port dataIn : SignalIF;
    }

    public part def PowerBus {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port configIn : CommandIF;
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
    public part autonomousroversystem : AutonomousRoverSystem;

}