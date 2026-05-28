package arch_000142 {

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

    // Component Definitions
    public part def MissionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
        port statusOut;
        port cmdOut;
    }

    public part def ThermalPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut;
        port cmdIn;
        port telemetryOut;
    }

    public part def FlightSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port telemetryOut;
    }

    public part def PowerPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataIn;
    }

    public part def ControlBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port dataIn;
    }

    public part def PowerInterface {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port dataOut;
        port dataOut;
    }

    public part def NavModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
        port statusOut;
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
    part roboticarmsystem : RoboticArmSystem;

}