package arch_000145 {

    // Thermal Control Reference Architecture 145
    // Domain: thermal control

    // Requirements
    requirement REQ_001 {
        doc "The thermal control system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The thermal control system shall trace subsystem design to requirements."
    }

    // Component Definitions
    part def FlightPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn;
        port cmdIn;
        port dataOut;
    }

    part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
        port sensorOut;
        port configIn;
    }

    part def DataInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
    }

    // System Definition
    part def ThermalControlSystem {
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