package arch_000159 {

    // Radar System Reference Architecture 159
    // Domain: radar system

    // Requirements
    public requirement REQ_001 {
        doc "The radar system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The radar system system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The radar system system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The radar system system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def FlightProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
        port dataIn;
    }

    public part def MonitorAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
        port pwrOut;
    }

    public part def ThermalProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut;
    }

    public part def FlightModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
    }

    public part def NavSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
        port sensorOut;
    }

    public part def DistributionComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port ctrlIn;
    }

    public part def DataPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut;
    }

    // System Definition
    public part def RadarSystemSystem {
        part flightprocessor : FlightProcessor {
        }
        part monitorassembly : MonitorAssembly {
        }
        part thermalprocessor : ThermalProcessor {
        }
        part flightmodule : FlightModule {
            satisfy REQ_003;
        }
        part navsubsystem : NavSubsystem {
            satisfy REQ_001;
        }
        part distributioncomputer : DistributionComputer {
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part datapayload : DataPayload {
            satisfy REQ_003;
            satisfy REQ_004;
        }

        // Connections
        connect navsubsystem.statusOut to monitorassembly.pwrOut;
        connect flightprocessor.pwrIn to navsubsystem.statusOut;
    }

    // System Instance
    part radarsystemsystem : RadarSystemSystem;

}