package arch_000089 {

    import ScalarValues::*;

    // Ground Station Reference Architecture 89
    // Domain: ground station

    // Requirements
    public requirement REQ_001 {
        doc "The ground station system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The ground station system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def MonitorModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : PowerIF;
        port configIn : DiagnosticIF;
        port pwrOut : ControlIF;
    }

    public part def FlightUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : CommandIF;
        port pwrOut : ThermalIF;
    }

    public part def ControlController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : StatusIF;
    }

    public part def DataAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : PowerIF;
        port telemetryOut : ControlIF;
    }

    public part def NavPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn : TelemetryIF;
        port pwrOut : SignalIF;
    }

    public part def ThermalActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut : DataIF;
        port dataIn : DiagnosticIF;
    }

    public part def MonitorUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : PowerIF;
    }

    // System Definition
    public part def GroundStationSystem {
        part monitormodule : MonitorModule {
            satisfy REQ_002;
        }
        part flightunit : FlightUnit {
        }
        part controlcontroller : ControlController {
        }
        part dataassembly : DataAssembly {
        }
        part navpayload : NavPayload {
            satisfy REQ_001;
        }
        part thermalactuator : ThermalActuator {
        }
        part monitorunit : MonitorUnit {
            satisfy REQ_001;
        }

        // Connections
        connect flightunit.pwrOut to thermalactuator.dataIn;
        connect monitormodule.configIn to thermalactuator.dataIn;
        connect monitormodule.configIn to navpayload.ctrlIn;
    }

    // System Instance
    public part groundstationsystem : GroundStationSystem;

}