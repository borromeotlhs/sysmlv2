package arch_000021 {

    import ScalarValues::*;

    // Power Distribution System Reference Architecture 21
    // Domain: power distribution system

    // Requirements
    public requirement REQ_001 {
        doc "The power distribution system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The power distribution system system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The power distribution system system shall provide fault detection and recovery."
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

    // Component Definitions
    public part def CommModule {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataIn : TelemetryIF;
        port cmdIn : PowerIF;
        port sensorOut : DiagnosticIF;
    }

    public part def DistributionSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : TelemetryIF;
        port cmdOut : ConfigIF;
    }

    public part def MissionAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn : PowerIF;
        port statusOut : PowerIF;
    }

    public part def ProcessingPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn : SignalIF;
    }

    public part def ProcessingSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : StatusIF;
        port telemetryOut : DataIF;
    }

    public part def CommInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port telemetryOut : ConfigIF;
        port statusOut : ControlIF;
    }

    // System Definition
    public part def PowerDistributionSystemSystem {
        part commmodule : CommModule {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part distributionsubsystem : DistributionSubsystem {
        }
        part missionassembly : MissionAssembly {
            satisfy REQ_003;
        }
        part processingpayload : ProcessingPayload {
        }
        part processingsubsystem : ProcessingSubsystem {
        }
        part comminterface : CommInterface {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect processingsubsystem.configIn to commmodule.dataIn;
        connect commmodule.cmdIn to distributionsubsystem.cmdOut;
        connect comminterface.telemetryOut to distributionsubsystem.cmdOut;
        connect comminterface.statusOut to commmodule.cmdIn;
        connect commmodule.cmdIn to comminterface.telemetryOut;
    }

    // System Instance
    public part powerdistributionsystemsystem : PowerDistributionSystemSystem;

}