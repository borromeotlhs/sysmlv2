package arch_000003 {

    import ScalarValues::*;

    // Instrument Platform Reference Architecture 3
    // Domain: instrument platform

    // Requirements
    public requirement REQ_001 {
        doc "The instrument platform system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The instrument platform system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The instrument platform system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def DataIF;
    public port def StatusIF;

    // Component Definitions
    public part def CommandInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port statusOut : StatusIF;
    }

    public part def CommActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port ctrlIn : ConfigIF;
        port pwrIn : ConfigIF;
        port cmdIn : DataIF;
    }

    // System Definition
    public part def InstrumentPlatformSystem {
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
    public part instrumentplatformsystem : InstrumentPlatformSystem;

}