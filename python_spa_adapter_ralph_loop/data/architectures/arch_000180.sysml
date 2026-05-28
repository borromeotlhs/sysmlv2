package arch_000180 {

    import ScalarValues::*;

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

    // Port Definitions
    public port def ConfigIF;
    public port def DataIF;
    public port def PowerIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def DataInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : ThermalIF;
        port cmdIn : PowerIF;
    }

    public part def ProcessingBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : DataIF;
    }

    public part def DataActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : ConfigIF;
    }

    public part def CommSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataOut : ConfigIF;
    }

    public part def ThermalProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : TelemetryIF;
    }

    public part def NavInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : ThermalIF;
        port dataOut : StatusIF;
    }

    public part def MissionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn : ThermalIF;
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
    public part autonomousroversystem : AutonomousRoverSystem;

}