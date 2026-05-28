package arch_000180 {

    // Autonomous Rover Reference Architecture 180
    // Domain: autonomous rover

    // Requirements
    public requirement REQ_001 {
        doc "The autonomous rover system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The autonomous rover system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The autonomous rover system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def DataInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
        port cmdIn;
    }

    public part def ProcessingBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
    }

    public part def DataActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
    }

    public part def CommSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataOut;
    }

    public part def ThermalProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
    }

    public part def NavInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port dataOut;
    }

    public part def MissionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn;
    }

    // System Definition
    public part def AutonomousRoverSystem {
        part datainterface : DataInterface {
            satisfy REQ_003;
        }
        part processingbus : ProcessingBus {
            satisfy REQ_002;
        }
        part dataactuator : DataActuator {
        }
        part commsensor : CommSensor {
            satisfy REQ_003;
        }
        part thermalprocessor : ThermalProcessor {
            satisfy REQ_001;
        }
        part navinterface : NavInterface {
        }
        part missioncontroller : MissionController {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect commsensor.dataOut to navinterface.dataOut;
        connect dataactuator.configIn to commsensor.dataOut;
        connect datainterface.cmdIn to thermalprocessor.statusOut;
        connect navinterface.dataIn to processingbus.dataIn;
    }

    // System Instance
    part autonomousroversystem : AutonomousRoverSystem;

}