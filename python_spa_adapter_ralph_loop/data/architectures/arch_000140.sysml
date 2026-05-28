package arch_000140 {

    // Power Distribution System Reference Architecture 140
    // Domain: power distribution system

    // Requirements
    public requirement REQ_001 {
        doc "The power distribution system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The power distribution system system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def DistributionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut;
        port statusOut;
        port cmdOut;
    }

    public part def ControlBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
    }

    public part def SensorSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn;
        port dataIn;
    }

    // System Definition
    public part def PowerDistributionSystemSystem {
        part distributionsensor : DistributionSensor {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part controlbus : ControlBus {
        }
        part sensorsensor : SensorSensor {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect distributionsensor.statusOut to sensorsensor.dataIn;
        connect distributionsensor.sensorOut to sensorsensor.dataIn;
        connect distributionsensor.sensorOut to controlbus.cmdIn;
        connect sensorsensor.pwrIn to distributionsensor.sensorOut;
    }

    // System Instance
    part powerdistributionsystemsystem : PowerDistributionSystemSystem;

}