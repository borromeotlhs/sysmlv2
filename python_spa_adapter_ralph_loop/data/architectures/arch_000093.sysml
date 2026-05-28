package arch_000093 {

    // Radar System Reference Architecture 93
    // Domain: radar system

    // Requirements
    public requirement REQ_001 {
        doc "The radar system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The radar system system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The radar system system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The radar system system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def CommandActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataOut;
        port statusOut;
    }

    public part def SensorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn;
        port statusOut;
        port pwrIn;
    }

    public part def DistributionInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
    }

    public part def MonitorSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut;
        port pwrIn;
        port cmdIn;
    }

    public part def SensorSubsystem {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut;
        port sensorOut;
        port statusOut;
    }

    public part def ThermalComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut;
        port pwrOut;
        port dataIn;
    }

    public part def ProcessingSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn;
        port pwrIn;
        port statusOut;
    }

    // System Definition
    public part def RadarSystemSystem {
        part commandactuator : CommandActuator {
        }
        part sensorcomputer : SensorComputer {
            satisfy REQ_002;
        }
        part distributioninterface : DistributionInterface {
        }
        part monitorsubsystem : MonitorSubsystem {
            satisfy REQ_004;
        }
        part sensorsubsystem : SensorSubsystem {
        }
        part thermalcomputer : ThermalComputer {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part processingsensor : ProcessingSensor {
            satisfy REQ_001;
        }

        // Connections
        connect monitorsubsystem.cmdIn to thermalcomputer.pwrOut;
        connect thermalcomputer.pwrOut to processingsensor.statusOut;
        connect processingsensor.configIn to distributioninterface.cmdOut;
        connect processingsensor.configIn to monitorsubsystem.cmdIn;
    }

    // System Instance
    part radarsystemsystem : RadarSystemSystem;

}