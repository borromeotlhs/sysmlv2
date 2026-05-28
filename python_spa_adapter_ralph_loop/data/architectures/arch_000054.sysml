package arch_000054 {

    // Robotic Arm Reference Architecture 54
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
    public part def MonitorSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn;
    }

    public part def MissionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
        port telemetryOut;
        port dataIn;
    }

    public part def NavBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
    }

    // System Definition
    public part def RoboticArmSystem {
        part monitorsensor : MonitorSensor {
            satisfy REQ_002;
        }
        part missionbus : MissionBus {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part navbus : NavBus {
            satisfy REQ_001;
            satisfy REQ_004;
        }

        // Connections
        connect missionbus.dataIn to monitorsensor.ctrlIn;
        connect navbus.pwrIn to missionbus.dataIn;
        connect navbus.pwrIn to monitorsensor.ctrlIn;
        connect missionbus.cmdOut to navbus.pwrIn;
    }

    // System Instance
    part roboticarmsystem : RoboticArmSystem;

}