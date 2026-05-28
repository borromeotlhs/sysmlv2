package arch_000093 {

    import ScalarValues::*;

    // Radar System Reference Architecture 93
    // Domain: radar system

    // Requirements
    public requirement REQ_001 {
        doc "The radar system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The radar system system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The radar system system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The radar system system shall maintain operational status monitoring."
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
        port dataOut : TelemetryIF;
        port statusOut : ControlIF;
    }

    public part def SensorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn : DataIF;
        port statusOut : PowerIF;
        port pwrIn : TelemetryIF;
    }

    public part def DistributionInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : SignalIF;
    }

    public part def MonitorSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut : StatusIF;
        port pwrIn : ThermalIF;
        port cmdIn : CommandIF;
    }

    public part def SensorSubsystem {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut : DataIF;
        port sensorOut : CommandIF;
        port statusOut : ThermalIF;
    }

    public part def ThermalComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut : StatusIF;
        port pwrOut : DataIF;
        port dataIn : StatusIF;
    }

    public part def ProcessingSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn : SignalIF;
        port pwrIn : ConfigIF;
        port statusOut : DiagnosticIF;
    }

    // System Definition
    public part def RadarSystemSystem {
        part commandactuator : CommandActuator {
        }
        part sensorcomputer : SensorComputer {
            satisfy REQ_002;
        }
        part distributioninterface : DistributionInterface {
        }
        part monitorsubsystem : MonitorSubsystem {
            satisfy REQ_004;
        }
        part sensorsubsystem : SensorSubsystem {
        }
        part thermalcomputer : ThermalComputer {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part processingsensor : ProcessingSensor {
            satisfy REQ_001;
        }

        // Connections
        connect monitorsubsystem.cmdIn to thermalcomputer.pwrOut;
        connect thermalcomputer.pwrOut to processingsensor.statusOut;
        connect processingsensor.configIn to distributioninterface.cmdOut;
        connect processingsensor.configIn to monitorsubsystem.cmdIn;
    }

    // System Instance
    public part radarsystemsystem : RadarSystemSystem;

}