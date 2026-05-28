package arch_000026 {

    // Uav Payload Reference Architecture 26
    // Domain: uav payload

    // Requirements
    public requirement REQ_001 {
        doc "The uav payload system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The uav payload system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The uav payload system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The uav payload system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def DistributionModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
    }

    public part def ControlAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
    }

    public part def MissionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut;
        port configIn;
    }

    public part def PowerComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut;
        port configIn;
    }

    // System Definition
    public part def UavPayloadSystem {
        part distributionmodule : DistributionModule {
            satisfy REQ_003;
        }
        part controlassembly : ControlAssembly {
            satisfy REQ_004;
        }
        part missionprocessor : MissionProcessor {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part powercomputer : PowerComputer {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect missionprocessor.configIn to powercomputer.configIn;
        connect distributionmodule.statusOut to missionprocessor.configIn;
        connect missionprocessor.pwrOut to powercomputer.sensorOut;
        connect distributionmodule.statusOut to controlassembly.cmdOut;
    }

    // System Instance
    part uavpayloadsystem : UavPayloadSystem;

}