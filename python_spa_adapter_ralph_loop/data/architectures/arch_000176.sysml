package arch_000176 {

    import ScalarValues::*;

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

    // Port Definitions
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def DistributionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : DiagnosticIF;
        port cmdOut : StatusIF;
        port cmdIn : ThermalIF;
    }

    public part def CommActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrIn : ConfigIF;
    }

    public part def DistributionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : DataIF;
        port dataOut : TelemetryIF;
    }

    public part def CommModule {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port sensorOut : DataIF;
        port pwrOut : DataIF;
    }

    public part def CommandActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port sensorOut : ControlIF;
    }

    public part def ProcessingSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : PowerIF;
        port pwrIn : ThermalIF;
    }

    public part def NavSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn : TelemetryIF;
        port cmdIn : DataIF;
        port telemetryOut : TelemetryIF;
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
    public part attitudecontrolsystem : AttitudeControlSystem;

}