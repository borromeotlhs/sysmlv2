package arch_000021 {

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

    // Component Definitions
    public part def CommModule {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataIn;
        port cmdIn;
        port sensorOut;
    }

    public part def DistributionSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
        port cmdOut;
    }

    public part def MissionAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
        port statusOut;
    }

    public part def ProcessingPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn;
    }

    public part def ProcessingSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port telemetryOut;
    }

    public part def CommInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port telemetryOut;
        port statusOut;
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
    part powerdistributionsystemsystem : PowerDistributionSystemSystem;

}