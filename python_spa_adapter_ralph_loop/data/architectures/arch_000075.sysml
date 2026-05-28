package arch_000075 {

    // Thermal Control Reference Architecture 75
    // Domain: thermal control

    // Requirements
    public requirement REQ_001 {
        doc "The thermal control system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The thermal control system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def CommandActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port cmdIn;
    }

    public part def ControlInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
        port pwrOut;
    }

    public part def ProcessingSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
        port telemetryOut;
    }

    public part def MissionSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
    }

    public part def ThermalBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port pwrIn;
        port configIn;
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
    part thermalcontrolsystem : ThermalControlSystem;

}