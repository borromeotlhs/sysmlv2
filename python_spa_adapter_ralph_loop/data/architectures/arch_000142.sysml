package arch_000142 {

    import ScalarValues::*;

    // Robotic Arm Reference Architecture 142
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

    // Port Definitions
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def MissionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : SignalIF;
        port statusOut : ThermalIF;
        port cmdOut : TelemetryIF;
    }

    public part def ThermalPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut : PowerIF;
        port cmdIn : TelemetryIF;
        port telemetryOut : DataIF;
    }

    public part def FlightSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : ConfigIF;
        port telemetryOut : DataIF;
    }

    public part def PowerPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataIn : StatusIF;
    }

    public part def ControlBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : DataIF;
        port dataIn : DataIF;
    }

    public part def PowerInterface {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port dataOut : ControlIF;
        port dataOut : DiagnosticIF;
    }

    public part def NavModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : ThermalIF;
        port statusOut : TelemetryIF;
    }

    // System Definition
    public part def RoboticArmSystem {
        part missioncontroller : MissionController {
            satisfy REQ_001;
        }
        part thermalpayload : ThermalPayload {
        }
        part flightsubsystem : FlightSubsystem {
        }
        part powerpayload : PowerPayload {
            satisfy REQ_002;
        }
        part controlbus : ControlBus {
        }
        part powerinterface : PowerInterface {
            satisfy REQ_003;
        }
        part navmodule : NavModule {
            satisfy REQ_002;
        }

        // Connections
        connect powerinterface.dataOut to controlbus.configIn;
        connect thermalpayload.cmdIn to powerinterface.dataOut;
        connect flightsubsystem.ctrlIn to thermalpayload.telemetryOut;
        connect powerpayload.dataIn to thermalpayload.cmdIn;
    }

    // System Instance
    public part roboticarmsystem : RoboticArmSystem;

}