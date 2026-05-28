package arch_000037 {

    // Attitude Control Reference Architecture 37
    // Domain: attitude control

    // Requirements
    public requirement REQ_001 {
        doc "The attitude control system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The attitude control system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The attitude control system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The attitude control system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def ProcessingInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port ctrlIn;
        port dataIn;
    }

    public part def CommandAssembly {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port cmdOut;
    }

    public part def SensorModule {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn;
        port statusOut;
    }

    public part def FlightModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
        port pwrOut;
        port ctrlIn;
    }

    public part def DistributionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut;
        port dataIn;
        port telemetryOut;
    }

    public part def DataPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataIn;
    }

    public part def MissionAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
        port sensorOut;
        port pwrIn;
    }

    // System Definition
    public part def AttitudeControlSystem {
        part processinginterface : ProcessingInterface {
        }
        part commandassembly : CommandAssembly {
            satisfy REQ_003;
        }
        part sensormodule : SensorModule {
        }
        part flightmodule : FlightModule {
        }
        part distributionprocessor : DistributionProcessor {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part datapayload : DataPayload {
        }
        part missionassembly : MissionAssembly {
            satisfy REQ_004;
        }

        // Connections
        connect distributionprocessor.dataIn to flightmodule.pwrOut;
        connect distributionprocessor.sensorOut to processinginterface.dataIn;
        connect sensormodule.ctrlIn to distributionprocessor.sensorOut;
    }

    // System Instance
    part attitudecontrolsystem : AttitudeControlSystem;

}