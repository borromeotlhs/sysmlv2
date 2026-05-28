package arch_000169 {

    import ScalarValues::*;

    // Ground Station Reference Architecture 169
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
    public port def ConfigIF;
    public port def ControlIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def ThermalIF;

    // Component Definitions
    public part def ControlSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : PowerIF;
        port ctrlIn : SignalIF;
        port configIn : ControlIF;
    }

    public part def SensorInterface {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut : CommandIF;
        port sensorOut : DiagnosticIF;
    }

    public part def DistributionAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : PowerIF;
        port cmdIn : ThermalIF;
        port sensorOut : ConfigIF;
    }

    public part def PowerActuator {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port statusOut : ControlIF;
    }

    // System Definition
    public part def GroundStationSystem {
        part controlsubsystem : ControlSubsystem {
        }
        part sensorinterface : SensorInterface {
            satisfy REQ_001;
        }
        part distributionassembly : DistributionAssembly {
        }
        part poweractuator : PowerActuator {
            satisfy REQ_002;
        }

        // Connections
        connect controlsubsystem.ctrlIn to distributionassembly.telemetryOut;
        connect sensorinterface.sensorOut to distributionassembly.cmdIn;
        connect distributionassembly.sensorOut to controlsubsystem.dataIn;
    }

    // System Instance
    public part groundstationsystem : GroundStationSystem;

}