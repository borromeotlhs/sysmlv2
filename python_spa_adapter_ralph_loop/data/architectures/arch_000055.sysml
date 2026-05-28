package arch_000055 {

    import ScalarValues::*;

    // Reaction Wheel Reference Architecture 55
    // Domain: reaction wheel

    // Requirements
    public requirement REQ_001 {
        doc "The reaction wheel system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The reaction wheel system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The reaction wheel system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def SignalIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def SensorActuator {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataIn : ControlIF;
        port cmdIn : TelemetryIF;
        port cmdOut : SignalIF;
    }

    public part def ProcessingActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : DataIF;
        port dataIn : ControlIF;
    }

    public part def DataPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut : TelemetryIF;
        port dataOut : ConfigIF;
    }

    public part def ThermalSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : TelemetryIF;
        port cmdOut : TelemetryIF;
    }

    public part def NavInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : ControlIF;
        port cmdOut : SignalIF;
        port cmdIn : DataIF;
    }

    public part def ControlBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : DataIF;
    }

    // System Definition
    public part def ReactionWheelSystem {
        part sensoractuator : SensorActuator {
            satisfy REQ_003;
        }
        part processingactuator : ProcessingActuator {
            satisfy REQ_002;
        }
        part datapayload : DataPayload {
        }
        part thermalsubsystem : ThermalSubsystem {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part navinterface : NavInterface {
        }
        part controlbus : ControlBus {
        }

        // Connections
        connect navinterface.cmdIn to processingactuator.cmdOut;
        connect sensoractuator.cmdOut to thermalsubsystem.cmdOut;
        connect datapayload.pwrOut to thermalsubsystem.cmdOut;
    }

    // System Instance
    public part reactionwheelsystem : ReactionWheelSystem;

}