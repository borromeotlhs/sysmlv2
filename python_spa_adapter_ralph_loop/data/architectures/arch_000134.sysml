package arch_000134 {

    import ScalarValues::*;

    // Life Support Reference Architecture 134
    // Domain: life support

    // Requirements
    public requirement REQ_001 {
        doc "The life support system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The life support system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The life support system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def ControlIF;
    public port def PowerIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def ThermalAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : ConfigIF;
        port dataOut : PowerIF;
        port pwrOut : ThermalIF;
    }

    public part def CommandInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port cmdOut : TelemetryIF;
        port configIn : ThermalIF;
        port dataOut : ControlIF;
    }

    // System Definition
    public part def LifeSupportSystem {
        part thermalassembly : ThermalAssembly {
            satisfy REQ_002;
        }
        part commandinterface : CommandInterface {
            satisfy REQ_001;
            satisfy REQ_003;
        }

        // Connections
        connect thermalassembly.pwrOut to commandinterface.configIn;
        connect commandinterface.cmdOut to thermalassembly.pwrOut;
        connect commandinterface.configIn to thermalassembly.cmdOut;
        connect commandinterface.cmdOut to thermalassembly.cmdOut;
    }

    // System Instance
    public part lifesupportsystem : LifeSupportSystem;

}