package arch_000171 {

    // Solar Array Reference Architecture 171
    // Domain: solar array

    // Requirements
    public requirement REQ_001 {
        doc "The solar array system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The solar array system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The solar array system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The solar array system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def ThermalModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
    }

    public part def PowerPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataIn;
        port configIn;
        port cmdOut;
    }

    // System Definition
    public part def SolarArraySystem {
        part thermalmodule : ThermalModule {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
            satisfy REQ_004;
        }
        part powerpayload : PowerPayload {
            satisfy REQ_002;
            satisfy REQ_003;
            satisfy REQ_004;
        }

        // Connections
        connect thermalmodule.pwrOut to powerpayload.dataIn;
        connect thermalmodule.pwrOut to powerpayload.configIn;
        connect thermalmodule.pwrOut to powerpayload.cmdOut;
    }

    // System Instance
    part solararraysystem : SolarArraySystem;

}