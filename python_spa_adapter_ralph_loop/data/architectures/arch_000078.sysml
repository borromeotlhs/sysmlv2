package arch_000078 {

    import ScalarValues::*;

    // Ground Station Reference Architecture 78
    // Domain: ground station

    // Requirements
    public requirement REQ_001 {
        doc "The ground station system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The ground station system shall trace subsystem design to requirements."
    }

    // Port Definitions
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
    public part def PowerBus {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port statusOut : ControlIF;
        port pwrOut : SignalIF;
    }

    public part def DistributionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn : TelemetryIF;
        port cmdOut : TelemetryIF;
        port cmdIn : DiagnosticIF;
    }

    public part def DistributionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn : DataIF;
        port ctrlIn : ThermalIF;
        port sensorOut : DataIF;
    }

    public part def MonitorAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : ConfigIF;
        port pwrIn : StatusIF;
        port cmdIn : PowerIF;
    }

    public part def MonitorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut : ControlIF;
    }

    public part def DataAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : TelemetryIF;
        port dataIn : ControlIF;
    }

    public part def DataBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : DataIF;
        port ctrlIn : ControlIF;
        port telemetryOut : PowerIF;
    }

    // System Definition
    public part def GroundStationSystem {
        part powerbus : PowerBus {
            satisfy REQ_002;
        }
        part distributionsensor : DistributionSensor {
        }
        part distributionprocessor : DistributionProcessor {
        }
        part monitorassembly : MonitorAssembly {
        }
        part monitorcontroller : MonitorController {
            satisfy REQ_001;
        }
        part dataassembly : DataAssembly {
        }
        part databus : DataBus {
            satisfy REQ_001;
        }

        // Connections
        connect databus.dataIn to monitorassembly.statusOut;
        connect databus.ctrlIn to distributionsensor.pwrIn;
        connect databus.ctrlIn to dataassembly.configIn;
        connect powerbus.pwrOut to distributionprocessor.ctrlIn;
    }

    // System Instance
    public part groundstationsystem : GroundStationSystem;

}