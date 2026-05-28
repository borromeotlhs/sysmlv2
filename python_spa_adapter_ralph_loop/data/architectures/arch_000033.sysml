package arch_000033 {

    import ScalarValues::*;

    // Antenna Subsystem Reference Architecture 33
    // Domain: antenna subsystem

    // Requirements
    public requirement REQ_001 {
        doc "The antenna subsystem system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The antenna subsystem system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The antenna subsystem system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The antenna subsystem system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def DistributionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : CommandIF;
    }

    public part def DistributionSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : ControlIF;
        port sensorOut : DataIF;
        port sensorOut : DataIF;
    }

    public part def SensorSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut : PowerIF;
        port pwrIn : TelemetryIF;
    }

    public part def CommProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn : StatusIF;
        port cmdOut : ThermalIF;
        port ctrlIn : ControlIF;
    }

    public part def DataActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : CommandIF;
    }

    // System Definition
    public part def AntennaSubsystemSystem {
        part distributionunit : DistributionUnit {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part distributionsubsystem : DistributionSubsystem {
            satisfy REQ_003;
        }
        part sensorsensor : SensorSensor {
            satisfy REQ_004;
        }
        part commprocessor : CommProcessor {
            satisfy REQ_001;
        }
        part dataactuator : DataActuator {
            satisfy REQ_003;
        }

        // Connections
        connect commprocessor.ctrlIn to sensorsensor.pwrIn;
        connect commprocessor.dataIn to distributionsubsystem.ctrlIn;
        connect distributionsubsystem.sensorOut to distributionunit.pwrIn;
        connect distributionsubsystem.ctrlIn to sensorsensor.pwrIn;
        connect sensorsensor.cmdOut to commprocessor.cmdOut;
    }

    // System Instance
    public part antennasubsystemsystem : AntennaSubsystemSystem;

}