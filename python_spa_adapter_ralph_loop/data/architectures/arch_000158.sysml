package arch_000158 {

    import ScalarValues::*;

    // Radar System Reference Architecture 158
    // Domain: radar system

    // Requirements
    public requirement REQ_001 {
        doc "The radar system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The radar system system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def DataModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : PowerIF;
        port sensorOut : CommandIF;
        port cmdOut : ControlIF;
    }

    public part def SensorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut : DiagnosticIF;
        port dataOut : DataIF;
    }

    public part def MissionAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : TelemetryIF;
        port pwrIn : ControlIF;
        port pwrOut : CommandIF;
    }

    public part def PowerAssembly {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port pwrIn : PowerIF;
        port sensorOut : DiagnosticIF;
        port telemetryOut : DataIF;
    }

    // System Definition
    public part def RadarSystemSystem {
        part datamodule : DataModule {
        }
        part sensorcomputer : SensorComputer {
            satisfy REQ_001;
        }
        part missionassembly : MissionAssembly {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part powerassembly : PowerAssembly {
            satisfy REQ_002;
        }

        // Connections
        connect datamodule.sensorOut to powerassembly.pwrIn;
        connect datamodule.cmdOut to powerassembly.telemetryOut;
    }

    // System Instance
    public part radarsystemsystem : RadarSystemSystem;

}