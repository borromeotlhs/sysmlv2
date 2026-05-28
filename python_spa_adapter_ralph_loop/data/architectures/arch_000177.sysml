package arch_000177 {

    // Satellite Bus Reference Architecture 177
    // Domain: satellite bus

    // Requirements
    public requirement REQ_001 {
        doc "The satellite bus system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The satellite bus system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def PowerController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
    }

    public part def SensorBus {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn;
        port ctrlIn;
        port dataIn;
    }

    public part def CommProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn;
        port dataOut;
        port cmdIn;
    }

    // System Definition
    public part def SatelliteBusSystem {
        part powercontroller : PowerController {
            satisfy REQ_002;
        }
        part sensorbus : SensorBus {
            satisfy REQ_001;
        }
        part commprocessor : CommProcessor {
        }

        // Connections
        connect sensorbus.dataIn to commprocessor.dataOut;
        connect sensorbus.dataIn to powercontroller.telemetryOut;
    }

    // System Instance
    part satellitebussystem : SatelliteBusSystem;

}