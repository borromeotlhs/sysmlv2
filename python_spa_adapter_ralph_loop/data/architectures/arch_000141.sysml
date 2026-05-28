package arch_000141 {

    import ScalarValues::*;

    // Thruster Assembly Reference Architecture 141
    // Domain: thruster assembly

    // Requirements
    public requirement REQ_001 {
        doc "The thruster assembly system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The thruster assembly system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;

    // Component Definitions
    public part def DistributionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut : PowerIF;
        port telemetryOut : ControlIF;
        port cmdIn : DataIF;
    }

    public part def ControlModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : DiagnosticIF;
    }

    // System Definition
    public part def ThrusterAssemblySystem {
        part distributioncontroller : DistributionController {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part controlmodule : ControlModule {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect distributioncontroller.telemetryOut to controlmodule.pwrIn;
        connect distributioncontroller.cmdIn to controlmodule.pwrIn;
        connect controlmodule.pwrIn to distributioncontroller.dataOut;
    }

    // System Instance
    public part thrusterassemblysystem : ThrusterAssemblySystem;

}