package arch_000077 {

    // Ground Station Reference Architecture 77
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

    public requirement REQ_004 {
        doc "The ground station system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def CommandActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port ctrlIn;
        port dataOut;
    }

    public part def DistributionComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
        port configIn;
    }

    public part def DataUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
        port sensorOut;
        port sensorOut;
    }

    public part def ControlUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
        port telemetryOut;
        port ctrlIn;
    }

    public part def ProcessingBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
        port pwrIn;
    }

    public part def MonitorUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port dataOut;
        port sensorOut;
    }

    public part def CommSubsystem {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port configIn;
    }

    // System Definition
    public part def GroundStationSystem {
        part commandactuator : CommandActuator {
        }
        part distributioncomputer : DistributionComputer {
            satisfy REQ_002;
        }
        part dataunit : DataUnit {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part controlunit : ControlUnit {
            satisfy REQ_004;
        }
        part processingbus : ProcessingBus {
        }
        part monitorunit : MonitorUnit {
            satisfy REQ_001;
        }
        part commsubsystem : CommSubsystem {
            satisfy REQ_002;
        }

        // Connections
        connect dataunit.cmdOut to commandactuator.ctrlIn;
        connect commsubsystem.configIn to controlunit.ctrlIn;
        connect monitorunit.telemetryOut to commandactuator.dataOut;
        connect dataunit.sensorOut to processingbus.pwrIn;
    }

    // System Instance
    part groundstationsystem : GroundStationSystem;

}