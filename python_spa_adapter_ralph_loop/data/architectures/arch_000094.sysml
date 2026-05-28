package arch_000094 {

    import ScalarValues::*;

    // Fuel Cell Reference Architecture 94
    // Domain: fuel cell

    // Requirements
    public requirement REQ_001 {
        doc "The fuel cell system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The fuel cell system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def CommandController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : CommandIF;
        port cmdOut : PowerIF;
    }

    public part def DataSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn : StatusIF;
        port cmdOut : DataIF;
    }

    public part def CommAssembly {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataOut : ControlIF;
        port cmdOut : DiagnosticIF;
    }

    public part def DistributionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port statusOut : StatusIF;
    }

    public part def ControlBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : ConfigIF;
        port pwrIn : DiagnosticIF;
        port cmdIn : PowerIF;
    }

    public part def MonitorBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : TelemetryIF;
        port cmdIn : ThermalIF;
        port telemetryOut : ConfigIF;
    }

    public part def MissionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut : CommandIF;
        port configIn : ConfigIF;
    }

    // System Definition
    public part def FuelCellSystem {
        part commandcontroller : CommandController {
        }
        part datasensor : DataSensor {
        }
        part commassembly : CommAssembly {
        }
        part distributionsensor : DistributionSensor {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part controlbus : ControlBus {
        }
        part monitorbus : MonitorBus {
            satisfy REQ_002;
        }
        part missionprocessor : MissionProcessor {
            satisfy REQ_001;
        }

        // Connections
        connect controlbus.cmdIn to datasensor.configIn;
        connect commandcontroller.telemetryOut to commassembly.cmdOut;
        connect monitorbus.ctrlIn to commandcontroller.telemetryOut;
    }

    // System Instance
    public part fuelcellsystem : FuelCellSystem;

}