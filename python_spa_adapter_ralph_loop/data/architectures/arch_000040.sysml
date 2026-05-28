package arch_000040 {

    // Robotic Arm Reference Architecture 40
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

    public requirement REQ_004 {
        doc "The robotic arm system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def FlightSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port dataIn;
        port statusOut;
    }

    public part def SensorPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut;
        port dataIn;
    }

    public part def DistributionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut;
        port sensorOut;
        port cmdIn;
    }

    public part def PowerActuator {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port pwrOut;
    }

    // System Definition
    public part def RoboticArmSystem {
        part flightsubsystem : FlightSubsystem {
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part sensorpayload : SensorPayload {
        }
        part distributionsensor : DistributionSensor {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part poweractuator : PowerActuator {
            satisfy REQ_001;
            satisfy REQ_003;
        }

        // Connections
        connect flightsubsystem.statusOut to poweractuator.pwrOut;
        connect flightsubsystem.statusOut to distributionsensor.sensorOut;
        connect sensorpayload.dataIn to distributionsensor.sensorOut;
        connect distributionsensor.cmdIn to sensorpayload.dataIn;
        connect flightsubsystem.configIn to distributionsensor.sensorOut;
    }

    // System Instance
    part roboticarmsystem : RoboticArmSystem;

}