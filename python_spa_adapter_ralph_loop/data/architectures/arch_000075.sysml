package arch_000075 {

    import ScalarValues::*;

    // Thermal Control Reference Architecture 75
    // Domain: thermal control

    // Requirements
    public requirement REQ_001 {
        doc "The thermal control system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The thermal control system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def CommandActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port cmdIn : TelemetryIF;
    }

    public part def ControlInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : CommandIF;
        port pwrOut : SignalIF;
    }

    public part def ProcessingSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : TelemetryIF;
        port telemetryOut : DataIF;
    }

    public part def MissionSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : SignalIF;
    }

    public part def ThermalBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : ControlIF;
        port pwrIn : StatusIF;
        port configIn : DataIF;
    }

    // System Definition
    public part def ThermalControlSystem {
        part commandactuator : CommandActuator {
        }
        part controlinterface : ControlInterface {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part processingsubsystem : ProcessingSubsystem {
        }
        part missionsubsystem : MissionSubsystem {
        }
        part thermalbus : ThermalBus {
        }

        // Connections
        connect thermalbus.pwrIn to processingsubsystem.pwrIn;
        connect missionsubsystem.dataIn to commandactuator.cmdIn;
        connect processingsubsystem.telemetryOut to thermalbus.configIn;
    }

    // System Instance
    public part thermalcontrolsystem : ThermalControlSystem;

}