package arch_000114 {

    // Lunar Habitat Reference Architecture 114
    // Domain: lunar habitat

    // Requirements
    public requirement REQ_001 {
        doc "The lunar habitat system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The lunar habitat system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The lunar habitat system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def ThermalBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
    }

    public part def MonitorBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port cmdOut;
        port statusOut;
    }

    public part def DistributionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn;
        port sensorOut;
        port cmdIn;
    }

    public part def ProcessingBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port dataIn;
    }

    // System Definition
    public part def LunarHabitatSystem {
        part thermalbus : ThermalBus {
        }
        part monitorbus : MonitorBus {
            satisfy REQ_003;
        }
        part distributionprocessor : DistributionProcessor {
            satisfy REQ_001;
        }
        part processingbus : ProcessingBus {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect thermalbus.cmdOut to distributionprocessor.cmdIn;
        connect distributionprocessor.dataIn to processingbus.configIn;
        connect thermalbus.cmdOut to distributionprocessor.dataIn;
    }

    // System Instance
    part lunarhabitatsystem : LunarHabitatSystem;

}