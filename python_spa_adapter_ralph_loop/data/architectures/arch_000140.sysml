package arch_000140 {

    import ScalarValues::*;

    // Power Distribution System Reference Architecture 140
    // Domain: power distribution system

    // Requirements
    public requirement REQ_001 {
        doc "The power distribution system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The power distribution system system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def ControlIF;
    public port def DataIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def DistributionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut : DataIF;
        port statusOut : TelemetryIF;
        port cmdOut : DataIF;
    }

    public part def ControlBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn : TelemetryIF;
    }

    public part def SensorSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn : ControlIF;
        port dataIn : TelemetryIF;
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
    public part powerdistributionsystemsystem : PowerDistributionSystemSystem;

}