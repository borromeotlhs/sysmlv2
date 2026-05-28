package arch_000118 {

    // Lunar Habitat Reference Architecture 118
    // Domain: lunar habitat

    // Requirements
    public requirement REQ_001 {
        doc "The lunar habitat system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The lunar habitat system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def SensorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
        port dataIn;
        port sensorOut;
    }

    public part def DistributionPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdIn;
    }

    public part def SensorProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut;
        port cmdIn;
    }

    public part def DataAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
    }

    public part def NavBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
    }

    // System Definition
    public part def LunarHabitatSystem {
        part sensorcomputer : SensorComputer {
        }
        part distributionpayload : DistributionPayload {
        }
        part sensorprocessor : SensorProcessor {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part dataassembly : DataAssembly {
        }
        part navbus : NavBus {
            satisfy REQ_002;
        }

        // Connections
        connect sensorcomputer.dataIn to sensorprocessor.sensorOut;
        connect sensorprocessor.sensorOut to distributionpayload.cmdIn;
    }

    // System Instance
    part lunarhabitatsystem : LunarHabitatSystem;

}