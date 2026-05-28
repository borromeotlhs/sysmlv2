package arch_000077 {

    import ScalarValues::*;

    // Ground Station Reference Architecture 77
    // Domain: ground station

    // Requirements
    public requirement REQ_001 {
        doc "The ground station system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The ground station system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The ground station system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The ground station system shall maintain operational status monitoring."
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
    public part def CommandActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port ctrlIn : SignalIF;
        port dataOut : TelemetryIF;
    }

    public part def DistributionComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : ConfigIF;
        port configIn : StatusIF;
    }

    public part def DataUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : CommandIF;
        port sensorOut : ControlIF;
        port sensorOut : DiagnosticIF;
    }

    public part def ControlUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : SignalIF;
        port telemetryOut : DataIF;
        port ctrlIn : DataIF;
    }

    public part def ProcessingBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : ControlIF;
        port pwrIn : SignalIF;
    }

    public part def MonitorUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : SignalIF;
        port dataOut : PowerIF;
        port sensorOut : ThermalIF;
    }

    public part def CommSubsystem {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port configIn : StatusIF;
    }

    // System Definition
    public part def GroundStationSystem {
        part commandactuator : CommandActuator {
        }
        part distributioncomputer : DistributionComputer {
            satisfy REQ_002;
        }
        part dataunit : DataUnit {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part controlunit : ControlUnit {
            satisfy REQ_004;
        }
        part processingbus : ProcessingBus {
        }
        part monitorunit : MonitorUnit {
            satisfy REQ_001;
        }
        part commsubsystem : CommSubsystem {
            satisfy REQ_002;
        }

        // Connections
        connect dataunit.cmdOut to commandactuator.ctrlIn;
        connect commsubsystem.configIn to controlunit.ctrlIn;
        connect monitorunit.telemetryOut to commandactuator.dataOut;
        connect dataunit.sensorOut to processingbus.pwrIn;
    }

    // System Instance
    public part groundstationsystem : GroundStationSystem;

}