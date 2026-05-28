package arch_000061 {

    import ScalarValues::*;

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

    // Port Definitions
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def ThermalIF;

    // Component Definitions
    public part def ControlBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : PowerIF;
        port dataOut : SignalIF;
    }

    public part def CommAssembly {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port cmdOut : ThermalIF;
        port sensorOut : DiagnosticIF;
        port configIn : DiagnosticIF;
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
    public part groundstationsystem : GroundStationSystem;

}