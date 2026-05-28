package arch_000048 {

    // Propulsion Module Reference Architecture 48
    // Domain: propulsion module

    // Requirements
    public requirement REQ_001 {
        doc "The propulsion module system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The propulsion module system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def CommandSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut;
    }

    public part def NavModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut;
        port dataIn;
    }

    public part def DataUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
    }

    public part def ProcessingProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
        port ctrlIn;
    }

    public part def DistributionPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut;
    }

    // System Definition
    public part def PropulsionModuleSystem {
        part commandsensor : CommandSensor {
        }
        part navmodule : NavModule {
        }
        part dataunit : DataUnit {
            satisfy REQ_002;
        }
        part processingprocessor : ProcessingProcessor {
            satisfy REQ_001;
        }
        part distributionpayload : DistributionPayload {
        }

        // Connections
        connect navmodule.dataIn to dataunit.pwrIn;
        connect commandsensor.sensorOut to distributionpayload.sensorOut;
    }

    // System Instance
    part propulsionmodulesystem : PropulsionModuleSystem;

}