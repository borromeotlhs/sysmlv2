package arch_000189 {

    import ScalarValues::*;

    // Solar Array Reference Architecture 189
    // Domain: solar array

    // Requirements
    public requirement REQ_001 {
        doc "The solar array system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The solar array system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The solar array system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The solar array system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def ControlIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def ThermalComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn : DiagnosticIF;
        port ctrlIn : SignalIF;
        port cmdOut : DiagnosticIF;
    }

    public part def FlightController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : TelemetryIF;
    }

    public part def NavInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : SignalIF;
        port configIn : PowerIF;
        port cmdOut : ControlIF;
    }

    public part def MonitorSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut : PowerIF;
    }

    public part def DataComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn : StatusIF;
        port sensorOut : ConfigIF;
    }

    // System Definition
    public part def SolarArraySystem {
        part thermalcomputer : ThermalComputer {
            satisfy REQ_001;
            satisfy REQ_004;
        }
        part flightcontroller : FlightController {
            satisfy REQ_003;
            satisfy REQ_004;
        }
        part navinterface : NavInterface {
            satisfy REQ_003;
        }
        part monitorsensor : MonitorSensor {
        }
        part datacomputer : DataComputer {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect thermalcomputer.ctrlIn to datacomputer.cmdIn;
        connect flightcontroller.statusOut to thermalcomputer.ctrlIn;
        connect datacomputer.sensorOut to thermalcomputer.cmdOut;
        connect datacomputer.cmdIn to monitorsensor.sensorOut;
        connect flightcontroller.statusOut to thermalcomputer.cmdOut;
    }

    // System Instance
    public part solararraysystem : SolarArraySystem;

}