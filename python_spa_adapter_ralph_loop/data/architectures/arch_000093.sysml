package arch_000093 {

    // Command Data Handling Reference Architecture 93
    // Domain: command data handling

    // Requirements
    requirement REQ_001 {
        doc "The command data handling system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The command data handling system shall trace subsystem design to requirements."
    }

    requirement REQ_003 {
        doc "The command data handling system shall provide fault detection and recovery."
    }

    // Component Definitions
    part def MonitorInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut;
        port statusOut;
        port configIn;
    }

    part def DistributionSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
    }

    part def ProcessingProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port ctrlIn;
    }

    part def NavProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
    }

    // System Definition
    part def CommandDataHandlingSystem {
        part monitorinterface : MonitorInterface {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part distributionsubsystem : DistributionSubsystem {
            satisfy REQ_003;
        }
        part processingprocessor : ProcessingProcessor {
        }
        part navprocessor : NavProcessor {
        }

        // Connections
        connect monitorinterface.statusOut to distributionsubsystem.telemetryOut;
        connect monitorinterface.configIn to distributionsubsystem.telemetryOut;
        connect monitorinterface.sensorOut to distributionsubsystem.telemetryOut;
        connect navprocessor.pwrIn to processingprocessor.ctrlIn;
    }

    // System Instance
    part commanddatahandlingsystem : CommandDataHandlingSystem;

}