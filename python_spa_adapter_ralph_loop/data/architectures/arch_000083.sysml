package arch_000083 {

    // Instrument Platform Reference Architecture 83
    // Domain: instrument platform

    // Requirements
    requirement REQ_001 {
        doc "The instrument platform system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The instrument platform system shall trace subsystem design to requirements."
    }

    requirement REQ_003 {
        doc "The instrument platform system shall provide fault detection and recovery."
    }

    // Component Definitions
    part def CommandInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port statusOut;
    }

    part def CommActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port ctrlIn;
        port pwrIn;
        port cmdIn;
    }

    // System Definition
    part def InstrumentPlatformSystem {
        part commandinterface : CommandInterface {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part commactuator : CommActuator {
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect commactuator.pwrIn to commandinterface.statusOut;
        connect commactuator.cmdIn to commandinterface.statusOut;
        connect commactuator.ctrlIn to commandinterface.statusOut;
    }

    // System Instance
    part instrumentplatformsystem : InstrumentPlatformSystem;

}