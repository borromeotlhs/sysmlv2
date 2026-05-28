package arch_000052 {

    import ScalarValues::*;

    // Robotic Arm Reference Architecture 52
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
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;

    // Component Definitions
    public part def CommProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut : DataIF;
        port pwrIn : PowerIF;
        port statusOut : PowerIF;
    }

    public part def MonitorActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : ControlIF;
        port pwrOut : DataIF;
        port cmdOut : CommandIF;
    }

    public part def MonitorSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : ControlIF;
        port pwrIn : DataIF;
    }

    public part def FlightActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : PowerIF;
    }

    public part def PowerModule {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port ctrlIn : ConfigIF;
        port sensorOut : ConfigIF;
    }

    // System Definition
    public part def RoboticArmSystem {
        part commprocessor : CommProcessor {
            satisfy REQ_004;
        }
        part monitoractuator : MonitorActuator {
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part monitorsubsystem : MonitorSubsystem {
            satisfy REQ_003;
        }
        part flightactuator : FlightActuator {
            satisfy REQ_001;
        }
        part powermodule : PowerModule {
            satisfy REQ_003;
        }

        // Connections
        connect commprocessor.pwrIn to monitoractuator.cmdOut;
        connect commprocessor.pwrIn to powermodule.ctrlIn;
        connect monitoractuator.cmdOut to monitorsubsystem.ctrlIn;
        connect monitoractuator.pwrOut to monitorsubsystem.ctrlIn;
        connect commprocessor.pwrIn to flightactuator.cmdOut;
    }

    // System Instance
    public part roboticarmsystem : RoboticArmSystem;

}