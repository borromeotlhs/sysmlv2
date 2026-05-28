package arch_000048 {

    import ScalarValues::*;

    // Propulsion Module Reference Architecture 48
    // Domain: propulsion module

    // Requirements
    public requirement REQ_001 {
        doc "The propulsion module system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The propulsion module system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def CommandSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut : StatusIF;
    }

    public part def NavModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut : ConfigIF;
        port dataIn : StatusIF;
    }

    public part def DataUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : ThermalIF;
    }

    public part def ProcessingProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : DataIF;
        port ctrlIn : ControlIF;
    }

    public part def DistributionPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut : ThermalIF;
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
    public part propulsionmodulesystem : PropulsionModuleSystem;

}