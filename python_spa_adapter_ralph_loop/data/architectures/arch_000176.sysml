package arch_000176 {

    // Attitude Control Reference Architecture 176
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
    public part def DistributionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port cmdOut;
        port cmdIn;
    }

    public part def CommActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrIn;
    }

    public part def DistributionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
        port dataOut;
    }

    public part def CommModule {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port sensorOut;
        port pwrOut;
    }

    public part def CommandActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port sensorOut;
    }

    public part def ProcessingSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port pwrIn;
    }

    public part def NavSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
        port cmdIn;
        port telemetryOut;
    }

    // System Definition
    public part def AttitudeControlSystem {
        part distributionunit : DistributionUnit {
        }
        part commactuator : CommActuator {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part distributionprocessor : DistributionProcessor {
        }
        part commmodule : CommModule {
            satisfy REQ_001;
        }
        part commandactuator : CommandActuator {
            satisfy REQ_004;
        }
        part processingsubsystem : ProcessingSubsystem {
        }
        part navsubsystem : NavSubsystem {
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect distributionprocessor.dataOut to navsubsystem.cmdIn;
        connect navsubsystem.telemetryOut to commactuator.pwrIn;
        connect distributionprocessor.telemetryOut to distributionunit.cmdOut;
        connect distributionprocessor.dataOut to processingsubsystem.pwrIn;
        connect commandactuator.sensorOut to processingsubsystem.pwrIn;
    }

    // System Instance
    part attitudecontrolsystem : AttitudeControlSystem;

}