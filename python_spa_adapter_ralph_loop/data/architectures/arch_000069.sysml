package arch_000069 {

    import ScalarValues::*;

    // Docking Mechanism Reference Architecture 69
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

    // Port Definitions
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def ThermalProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn : ControlIF;
        port configIn : DiagnosticIF;
        port dataIn : DiagnosticIF;
    }

    public part def CommandModule {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port ctrlIn : ConfigIF;
    }

    public part def ControlAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : TelemetryIF;
        port cmdIn : DataIF;
    }

    public part def DistributionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : DiagnosticIF;
    }

    public part def ProcessingAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn : ConfigIF;
    }

    // System Definition
    public part def DockingMechanismSystem {
        part thermalprocessor : ThermalProcessor {
        }
        part commandmodule : CommandModule {
            satisfy REQ_001;
        }
        part controlassembly : ControlAssembly {
            satisfy REQ_002;
        }
        part distributionbus : DistributionBus {
            satisfy REQ_002;
        }
        part processingassembly : ProcessingAssembly {
            satisfy REQ_001;
            satisfy REQ_003;
        }

        // Connections
        connect thermalprocessor.cmdIn to controlassembly.cmdIn;
        connect commandmodule.ctrlIn to thermalprocessor.dataIn;
        connect thermalprocessor.dataIn to controlassembly.cmdIn;
        connect controlassembly.cmdIn to thermalprocessor.configIn;
        connect distributionbus.dataOut to thermalprocessor.configIn;
    }

    // System Instance
    public part dockingmechanismsystem : DockingMechanismSystem;

}