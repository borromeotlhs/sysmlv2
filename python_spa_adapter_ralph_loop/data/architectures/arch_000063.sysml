package arch_000063 {

    // Attitude Control Reference Architecture 63
    // Domain: attitude control

    // Requirements
    public requirement REQ_001 {
        doc "The attitude control system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The attitude control system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def ProcessingModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
    }

    public part def MissionModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
    }

    public part def FlightSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
        port ctrlIn;
        port sensorOut;
    }

    public part def FlightPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn;
        port pwrOut;
        port pwrIn;
    }

    public part def ControlActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
    }

    // System Definition
    public part def AttitudeControlSystem {
        part processingmodule : ProcessingModule {
            satisfy REQ_001;
        }
        part missionmodule : MissionModule {
        }
        part flightsubsystem : FlightSubsystem {
        }
        part flightpayload : FlightPayload {
        }
        part controlactuator : ControlActuator {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect controlactuator.pwrOut to missionmodule.cmdIn;
        connect missionmodule.cmdIn to flightpayload.pwrIn;
        connect controlactuator.pwrOut to flightpayload.pwrIn;
        connect flightpayload.pwrIn to flightsubsystem.cmdIn;
    }

    // System Instance
    part attitudecontrolsystem : AttitudeControlSystem;

}