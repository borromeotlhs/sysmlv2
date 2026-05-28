package arch_000136 {

    import ScalarValues::*;

    // Docking Mechanism Reference Architecture 136
    // Domain: docking mechanism

    // Requirements
    public requirement REQ_001 {
        doc "The docking mechanism system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The docking mechanism system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The docking mechanism system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The docking mechanism system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;
    public port def StatusIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def NavUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn : ControlIF;
        port pwrOut : PowerIF;
        port pwrOut : TelemetryIF;
    }

    public part def ThermalProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn : ConfigIF;
        port pwrIn : DataIF;
        port cmdIn : StatusIF;
    }

    public part def DataSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataIn : TelemetryIF;
        port pwrOut : PowerIF;
    }

    // System Definition
    public part def DockingMechanismSystem {
        part navunit : NavUnit {
            satisfy REQ_002;
        }
        part thermalprocessor : ThermalProcessor {
            satisfy REQ_003;
            satisfy REQ_004;
        }
        part datasensor : DataSensor {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect datasensor.pwrOut to thermalprocessor.pwrIn;
        connect navunit.pwrOut to datasensor.pwrOut;
    }

    // System Instance
    public part dockingmechanismsystem : DockingMechanismSystem;

}