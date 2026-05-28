package arch_000166 {

    import ScalarValues::*;

    // Fuel Cell Reference Architecture 166
    // Domain: fuel cell

    // Requirements
    public requirement REQ_001 {
        doc "The fuel cell system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The fuel cell system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The fuel cell system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The fuel cell system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def MonitorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut : TelemetryIF;
    }

    public part def SensorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut : TelemetryIF;
        port cmdIn : ThermalIF;
    }

    public part def MonitorPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdIn : SignalIF;
        port telemetryOut : ControlIF;
        port dataOut : DataIF;
    }

    public part def ThermalSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : SignalIF;
        port dataOut : ThermalIF;
        port ctrlIn : ControlIF;
    }

    public part def ControlAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : TelemetryIF;
    }

    public part def CommProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn : ThermalIF;
        port cmdIn : ThermalIF;
        port telemetryOut : StatusIF;
    }

    public part def DistributionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : DiagnosticIF;
    }

    // System Definition
    public part def FuelCellSystem {
        part monitorcontroller : MonitorController {
            satisfy REQ_004;
        }
        part sensorcomputer : SensorComputer {
            satisfy REQ_001;
        }
        part monitorpayload : MonitorPayload {
        }
        part thermalsubsystem : ThermalSubsystem {
            satisfy REQ_004;
        }
        part controlassembly : ControlAssembly {
            satisfy REQ_003;
        }
        part commprocessor : CommProcessor {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part distributionbus : DistributionBus {
        }

        // Connections
        connect sensorcomputer.cmdIn to thermalsubsystem.ctrlIn;
        connect controlassembly.pwrIn to commprocessor.configIn;
        connect controlassembly.pwrIn to sensorcomputer.cmdIn;
        connect sensorcomputer.cmdIn to monitorpayload.telemetryOut;
        connect distributionbus.pwrIn to monitorpayload.cmdIn;
    }

    // System Instance
    public part fuelcellsystem : FuelCellSystem;

}