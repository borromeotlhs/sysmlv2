package arch_000045 {

    // Robotic Arm Reference Architecture 45
    // Domain: robotic arm

    // Requirements
    public requirement REQ_001 {
        doc "The robotic arm system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The robotic arm system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The robotic arm system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def CommandAssembly {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port configIn;
    }

    public part def SensorPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut;
    }

    public part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
    }

    // System Definition
    public part def RoboticArmSystem {
        part commandassembly : CommandAssembly {
            satisfy REQ_003;
        }
        part sensorpayload : SensorPayload {
        }
        part flightinterface : FlightInterface {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect sensorpayload.sensorOut to flightinterface.ctrlIn;
        connect flightinterface.ctrlIn to commandassembly.configIn;
    }

    // System Instance
    part roboticarmsystem : RoboticArmSystem;

}