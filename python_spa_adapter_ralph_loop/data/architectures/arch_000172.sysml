package arch_000172 {

    import ScalarValues::*;

    // Radar System Reference Architecture 172
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

    // Port Definitions
    public port def ConfigIF;
    public port def ControlIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def ControlSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : ThermalIF;
    }

    public part def MonitorActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : SignalIF;
        port statusOut : StatusIF;
    }

    public part def MonitorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn : ControlIF;
        port pwrIn : ConfigIF;
        port cmdOut : PowerIF;
    }

    public part def DataModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : TelemetryIF;
    }

    // System Definition
    public part def RadarSystemSystem {
        part controlsubsystem : ControlSubsystem {
        }
        part monitoractuator : MonitorActuator {
        }
        part monitorcomputer : MonitorComputer {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part datamodule : DataModule {
        }

        // Connections
        connect monitoractuator.dataOut to monitorcomputer.pwrIn;
        connect monitorcomputer.pwrIn to monitoractuator.statusOut;
        connect monitoractuator.statusOut to datamodule.pwrIn;
        connect monitorcomputer.dataIn to controlsubsystem.ctrlIn;
    }

    // System Instance
    public part radarsystemsystem : RadarSystemSystem;

}