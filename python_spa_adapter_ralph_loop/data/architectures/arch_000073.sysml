package arch_000073 {

    // Antenna Subsystem Reference Architecture 73
    // Domain: antenna subsystem

    // Requirements
    public requirement REQ_001 {
        doc "The antenna subsystem system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The antenna subsystem system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The antenna subsystem system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def PowerPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn;
    }

    public part def NavUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
    }

    // System Definition
    public part def AntennaSubsystemSystem {
        part powerpayload : PowerPayload {
            satisfy REQ_002;
        }
        part navunit : NavUnit {
            satisfy REQ_001;
            satisfy REQ_003;
        }

        // Connections
        connect navunit.dataIn to powerpayload.pwrIn;
    }

    // System Instance
    part antennasubsystemsystem : AntennaSubsystemSystem;

}