package arch_000070 {

    import ScalarValues::*;

    // Attitude Control Reference Architecture 70
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

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def ThermalIF;

    // Component Definitions
    public part def DistributionAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn : DiagnosticIF;
    }

    public part def DataInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : CommandIF;
        port dataIn : DiagnosticIF;
    }

    public part def ControlProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn : ThermalIF;
        port telemetryOut : DiagnosticIF;
    }

    public part def CommUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port ctrlIn : PowerIF;
    }

    public part def ProcessingBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : ThermalIF;
        port pwrOut : ControlIF;
    }

    public part def PowerProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : DataIF;
    }

    // System Definition
    public part def AttitudeControlSystem {
        part distributionassembly : DistributionAssembly {
            satisfy REQ_002;
        }
        part datainterface : DataInterface {
            satisfy REQ_003;
        }
        part controlprocessor : ControlProcessor {
            satisfy REQ_001;
        }
        part communit : CommUnit {
            satisfy REQ_002;
        }
        part processingbus : ProcessingBus {
            satisfy REQ_001;
        }
        part powerprocessor : PowerProcessor {
        }

        // Connections
        connect processingbus.pwrOut to distributionassembly.cmdIn;
        connect datainterface.configIn to communit.ctrlIn;
        connect datainterface.configIn to distributionassembly.cmdIn;
        connect processingbus.cmdOut to datainterface.dataIn;
    }

    // System Instance
    public part attitudecontrolsystem : AttitudeControlSystem;

}