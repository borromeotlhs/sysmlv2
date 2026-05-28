package arch_000025 {

    // Thermal Control Reference Architecture 25
    // Domain: thermal control

    // Requirements
    public requirement REQ_001 {
        doc "The thermal control system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The thermal control system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def FlightPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn;
        port cmdIn;
        port dataOut;
    }

    public part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
        port sensorOut;
        port configIn;
    }

    public part def DataInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
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
    part thermalcontrolsystem : ThermalControlSystem;

}