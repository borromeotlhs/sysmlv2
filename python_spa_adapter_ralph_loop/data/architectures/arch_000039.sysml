package arch_000039 {

    // Propulsion Module Reference Architecture 39
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

    // Component Definitions
    public part def ControlSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port ctrlIn;
    }

    public part def DataProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
    }

    public part def ThermalActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
        port configIn;
    }

    public part def ProcessingAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
    }

    public part def NavSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn;
        port pwrIn;
    }

    // System Definition
    public part def PropulsionModuleSystem {
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