package arch_000061 {

    // Ground Station Reference Architecture 61
    // Domain: ground station

    // Requirements
    public requirement REQ_001 {
        doc "The ground station system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The ground station system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The ground station system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def ControlBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
        port dataOut;
    }

    public part def CommAssembly {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port cmdOut;
        port sensorOut;
        port configIn;
    }

    // System Definition
    public part def GroundStationSystem {
        part controlbus : ControlBus {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part commassembly : CommAssembly {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect controlbus.pwrOut to commassembly.cmdOut;
        connect commassembly.configIn to controlbus.dataOut;
        connect controlbus.dataOut to commassembly.sensorOut;
        connect controlbus.pwrOut to commassembly.configIn;
    }

    // System Instance
    part groundstationsystem : GroundStationSystem;

}