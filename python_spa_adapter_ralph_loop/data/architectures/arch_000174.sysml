package arch_000174 {

    // Ground Station Reference Architecture 174
    // Domain: ground station

    // Requirements
    public requirement REQ_001 {
        doc "The ground station system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The ground station system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The ground station system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def CommandUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port sensorOut;
        port pwrOut;
    }

    public part def ProcessingComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn;
    }

    public part def NavInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
    }

    public part def ThermalAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port configIn;
        port statusOut;
    }

    public part def DataSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
    }

    public part def CommInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port statusOut;
        port ctrlIn;
        port pwrOut;
    }

    // System Definition
    public part def GroundStationSystem {
        part commandunit : CommandUnit {
        }
        part processingcomputer : ProcessingComputer {
            satisfy REQ_001;
        }
        part navinterface : NavInterface {
        }
        part thermalassembly : ThermalAssembly {
            satisfy REQ_003;
        }
        part datasubsystem : DataSubsystem {
            satisfy REQ_002;
        }
        part comminterface : CommInterface {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect comminterface.pwrOut to thermalassembly.telemetryOut;
        connect processingcomputer.configIn to commandunit.pwrOut;
        connect comminterface.statusOut to processingcomputer.configIn;
        connect comminterface.ctrlIn to datasubsystem.statusOut;
        connect processingcomputer.configIn to navinterface.dataIn;
    }

    // System Instance
    part groundstationsystem : GroundStationSystem;

}