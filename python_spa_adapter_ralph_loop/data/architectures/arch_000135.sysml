package arch_000135 {

    // Satellite Bus Reference Architecture 135
    // Domain: satellite bus

    // Requirements
    public requirement REQ_001 {
        doc "The satellite bus system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The satellite bus system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def CommandPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn;
        port pwrIn;
    }

    public part def CommandModule {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port cmdIn;
    }

    public part def SensorInterface {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut;
        port statusOut;
        port pwrOut;
    }

    public part def MissionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port sensorOut;
    }

    public part def CommInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrIn;
        port dataIn;
    }

    public part def SensorProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
    }

    public part def NavAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
        port cmdIn;
    }

    // System Definition
    public part def SatelliteBusSystem {
        part commandpayload : CommandPayload {
            satisfy REQ_001;
        }
        part commandmodule : CommandModule {
        }
        part sensorinterface : SensorInterface {
            satisfy REQ_002;
        }
        part missionunit : MissionUnit {
        }
        part comminterface : CommInterface {
        }
        part sensorprocessor : SensorProcessor {
        }
        part navassembly : NavAssembly {
        }

        // Connections
        connect sensorinterface.statusOut to missionunit.sensorOut;
        connect comminterface.dataIn to commandmodule.cmdIn;
        connect sensorinterface.statusOut to commandmodule.cmdIn;
        connect sensorprocessor.pwrIn to navassembly.cmdIn;
    }

    // System Instance
    part satellitebussystem : SatelliteBusSystem;

}