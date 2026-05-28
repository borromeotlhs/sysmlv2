package arch_000116 {

    import ScalarValues::*;

    // Docking Mechanism Reference Architecture 116
    // Domain: docking mechanism

    // Requirements
    public requirement REQ_001 {
        doc "The docking mechanism system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The docking mechanism system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def MonitorSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn : ControlIF;
        port dataIn : DiagnosticIF;
        port configIn : TelemetryIF;
    }

    public part def FlightPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut : TelemetryIF;
        port ctrlIn : PowerIF;
        port configIn : ThermalIF;
    }

    public part def ProcessingBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : ThermalIF;
        port cmdIn : DataIF;
        port cmdIn : TelemetryIF;
    }

    public part def ControlBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : ThermalIF;
        port configIn : StatusIF;
        port statusOut : CommandIF;
    }

    public part def PowerSubsystem {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port pwrOut : ConfigIF;
        port telemetryOut : ThermalIF;
    }

    public part def ControlAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : ThermalIF;
    }

    public part def PowerSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn : SignalIF;
        port cmdOut : SignalIF;
        port pwrIn : ConfigIF;
    }

    // System Definition
    public part def DockingMechanismSystem {
        part monitorsensor : MonitorSensor {
        }
        part flightpayload : FlightPayload {
        }
        part processingbus : ProcessingBus {
        }
        part controlbus : ControlBus {
            satisfy REQ_002;
        }
        part powersubsystem : PowerSubsystem {
            satisfy REQ_001;
        }
        part controlassembly : ControlAssembly {
        }
        part powersensor : PowerSensor {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect monitorsensor.configIn to flightpayload.telemetryOut;
        connect powersubsystem.pwrOut to monitorsensor.configIn;
        connect processingbus.pwrIn to controlbus.configIn;
        connect monitorsensor.dataIn to flightpayload.ctrlIn;
    }

    // System Instance
    public part dockingmechanismsystem : DockingMechanismSystem;

}