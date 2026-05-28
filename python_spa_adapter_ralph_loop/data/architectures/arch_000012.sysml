package arch_000012 {

    import ScalarValues::*;

    // Solar Array Reference Architecture 12
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

    // Port Definitions
    public port def ControlIF;
    public port def DataIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def PowerPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut : ControlIF;
        port sensorOut : DataIF;
    }

    public part def FlightBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : ThermalIF;
    }

    public part def PowerModule {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port dataIn : ThermalIF;
        port cmdOut : StatusIF;
    }

    // System Definition
    public part def SolarArraySystem {
        part powerpayload : PowerPayload {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part flightbus : FlightBus {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part powermodule : PowerModule {
            satisfy REQ_001;
        }

        // Connections
        connect flightbus.dataIn to powermodule.cmdOut;
        connect powermodule.dataIn to powerpayload.pwrOut;
        connect powermodule.cmdOut to powerpayload.pwrOut;
        connect powerpayload.pwrOut to flightbus.dataIn;
    }

    // System Instance
    public part solararraysystem : SolarArraySystem;

}