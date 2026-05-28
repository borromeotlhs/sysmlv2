package arch_000074 {

    // Communication Relay Reference Architecture 74
    // Domain: communication relay

    // Requirements
    public requirement REQ_001 {
        doc "The communication relay system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The communication relay system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The communication relay system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def DataModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
        port telemetryOut;
        port configIn;
    }

    public part def CommandComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut;
        port statusOut;
    }

    public part def CommController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut;
        port pwrIn;
    }

    // System Definition
    public part def CommunicationRelaySystem {
        part datamodule : DataModule {
            satisfy REQ_003;
        }
        part commandcomputer : CommandComputer {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part commcontroller : CommController {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect commcontroller.pwrIn to datamodule.statusOut;
        connect commcontroller.pwrIn to commandcomputer.cmdOut;
        connect commandcomputer.cmdOut to datamodule.telemetryOut;
        connect commandcomputer.statusOut to commcontroller.pwrIn;
        connect datamodule.statusOut to commandcomputer.statusOut;
    }

    // System Instance
    part communicationrelaysystem : CommunicationRelaySystem;

}