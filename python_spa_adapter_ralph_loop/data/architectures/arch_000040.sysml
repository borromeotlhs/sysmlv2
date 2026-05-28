package arch_000040 {

    import ScalarValues::*;

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

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def FlightSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : DataIF;
        port dataIn : DataIF;
        port statusOut : ControlIF;
    }

    public part def SensorPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut : ControlIF;
        port dataIn : ThermalIF;
    }

    public part def DistributionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut : StatusIF;
        port sensorOut : CommandIF;
        port cmdIn : CommandIF;
    }

    public part def PowerActuator {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port pwrOut : TelemetryIF;
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
    public part roboticarmsystem : RoboticArmSystem;

}