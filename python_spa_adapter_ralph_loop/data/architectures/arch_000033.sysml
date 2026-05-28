package arch_000033 {

    // Antenna Subsystem Reference Architecture 33
    // Domain: antenna subsystem

    // Requirements
    requirement REQ_001 {
        doc "The antenna subsystem system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The antenna subsystem system shall trace subsystem design to requirements."
    }

    requirement REQ_003 {
        doc "The antenna subsystem system shall provide fault detection and recovery."
    }

    requirement REQ_004 {
        doc "The antenna subsystem system shall maintain operational status monitoring."
    }

    // Component Definitions
    part def DistributionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
    }

    part def DistributionSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port sensorOut;
        port sensorOut;
    }

    part def SensorSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut;
        port pwrIn;
    }

    part def CommProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn;
        port cmdOut;
        port ctrlIn;
    }

    part def DataActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
    }

    // System Definition
    part def AntennaSubsystemSystem {
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
    part antennasubsystemsystem : AntennaSubsystemSystem;

}