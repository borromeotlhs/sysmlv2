package arch_000079 {

    // Propulsion Module Reference Architecture 79
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
    part def ControlSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port ctrlIn;
    }

    part def DataProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
    }

    part def ThermalActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
        port configIn;
    }

    part def ProcessingAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
    }

    part def NavSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn;
        port pwrIn;
    }

    // System Definition
    part def PropulsionModuleSystem {
        part controlsubsystem : ControlSubsystem {
        }
        part dataprocessor : DataProcessor {
        }
        part thermalactuator : ThermalActuator {
            satisfy REQ_003;
        }
        part processingassembly : ProcessingAssembly {
            satisfy REQ_001;
        }
        part navsensor : NavSensor {
            satisfy REQ_002;
        }

        // Connections
        connect controlsubsystem.ctrlIn to navsensor.configIn;
        connect thermalactuator.configIn to processingassembly.cmdIn;
    }

    // System Instance
    part propulsionmodulesystem : PropulsionModuleSystem;

}