package arch_000058 {

    import ScalarValues::*;

    // Propulsion Module Reference Architecture 58
    // Domain: propulsion module

    // Requirements
    public requirement REQ_001 {
        doc "The propulsion module system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The propulsion module system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The propulsion module system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The propulsion module system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def DiagnosticIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def NavUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : ThermalIF;
        port dataOut : DiagnosticIF;
    }

    public part def ThermalController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut : DiagnosticIF;
        port telemetryOut : StatusIF;
        port dataIn : DiagnosticIF;
    }

    // System Definition
    public part def PropulsionModuleSystem {
        part navunit : NavUnit {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
            satisfy REQ_004;
        }
        part thermalcontroller : ThermalController {
            satisfy REQ_003;
            satisfy REQ_004;
        }

        // Connections
        connect navunit.cmdOut to thermalcontroller.dataIn;
        connect navunit.dataOut to thermalcontroller.pwrOut;
        connect thermalcontroller.telemetryOut to navunit.cmdOut;
    }

    // System Instance
    public part propulsionmodulesystem : PropulsionModuleSystem;

}