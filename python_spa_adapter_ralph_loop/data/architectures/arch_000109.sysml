package arch_000109 {

    // Propulsion Module Reference Architecture 109
    // Domain: propulsion module

    // Requirements
    requirement REQ_001 {
        doc "The propulsion module system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The propulsion module system shall trace subsystem design to requirements."
    }

    requirement REQ_003 {
        doc "The propulsion module system shall provide fault detection and recovery."
    }

    // Component Definitions
    part def DistributionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn;
    }

    part def DistributionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
        port dataIn;
        port sensorOut;
    }

    part def PowerAssembly {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port sensorOut;
        port cmdOut;
        port cmdIn;
    }

    // System Definition
    part def PropulsionModuleSystem {
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
    part propulsionmodulesystem : PropulsionModuleSystem;

}