package arch_000029 {

    import ScalarValues::*;

    // Propulsion Module Reference Architecture 29
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

    // Port Definitions
    public port def ControlIF;
    public port def PowerIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def DistributionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn : TelemetryIF;
    }

    public part def DistributionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : PowerIF;
        port dataIn : StatusIF;
        port sensorOut : ThermalIF;
    }

    public part def PowerAssembly {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port sensorOut : ControlIF;
        port cmdOut : StatusIF;
        port cmdIn : StatusIF;
    }

    // System Definition
    public part def PropulsionModuleSystem {
        part distributionprocessor : DistributionProcessor {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part distributionunit : DistributionUnit {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part powerassembly : PowerAssembly {
            satisfy REQ_003;
        }

        // Connections
        connect distributionunit.sensorOut to distributionprocessor.cmdIn;
        connect powerassembly.sensorOut to distributionunit.sensorOut;
    }

    // System Instance
    public part propulsionmodulesystem : PropulsionModuleSystem;

}