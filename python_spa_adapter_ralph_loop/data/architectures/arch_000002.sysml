package arch_000002 {

    import ScalarValues::*;

    // Autonomous Rover Reference Architecture 2
    // Domain: autonomous rover

    // Requirements
    public requirement REQ_001 {
        doc "The autonomous rover system shall exchange command and data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The autonomous rover system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def DataIF;
    public port def PowerIF;

    // Component Definitions
    public part def MissionComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut : CommandIF;
    }

    public part def SensorPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataOut : DataIF;
    }

    public part def PowerUnit {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port pwrOut : PowerIF;
    }

    // System Definition
    public part def AutonomousRoverSystem {
        part missioncomputer : MissionComputer {
            satisfy REQ_001;
        }
        part sensorpayload : SensorPayload {
            satisfy REQ_002;
        }
        part powerunit : PowerUnit {
        }

        // Connections
        connect missioncomputer.cmdOut to sensorpayload.dataOut;
        connect powerunit.pwrOut to sensorpayload.dataOut;
    }

    // System Instance
    public part autonomousroversystem : AutonomousRoverSystem;

}