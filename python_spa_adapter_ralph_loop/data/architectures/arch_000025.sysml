package arch_000025 {

    import ScalarValues::*;

    // Thermal Control Reference Architecture 25
    // Domain: thermal control

    // Requirements
    public requirement REQ_001 {
        doc "The thermal control system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The thermal control system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;
    public port def ThermalIF;

    // Component Definitions
    public part def FlightPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn : CommandIF;
        port cmdIn : ControlIF;
        port dataOut : PowerIF;
    }

    public part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : DataIF;
        port sensorOut : ThermalIF;
        port configIn : ThermalIF;
    }

    public part def DataInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : PowerIF;
    }

    // System Definition
    public part def ThermalControlSystem {
        part flightpayload : FlightPayload {
            satisfy REQ_002;
        }
        part flightinterface : FlightInterface {
        }
        part datainterface : DataInterface {
            satisfy REQ_001;
        }

        // Connections
        connect flightpayload.dataOut to datainterface.pwrOut;
        connect flightpayload.cmdIn to flightinterface.sensorOut;
    }

    // System Instance
    public part thermalcontrolsystem : ThermalControlSystem;

}