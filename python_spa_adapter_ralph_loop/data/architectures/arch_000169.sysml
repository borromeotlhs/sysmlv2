package arch_000169 {

    // Ground Station Reference Architecture 169
    // Domain: ground station

    // Requirements
    public requirement REQ_001 {
        doc "The ground station system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The ground station system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def ControlSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port ctrlIn;
        port configIn;
    }

    public part def SensorInterface {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut;
        port sensorOut;
    }

    public part def DistributionAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port cmdIn;
        port sensorOut;
    }

    public part def PowerActuator {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port statusOut;
    }

    // System Definition
    public part def GroundStationSystem {
        part controlsubsystem : ControlSubsystem {
        }
        part sensorinterface : SensorInterface {
            satisfy REQ_001;
        }
        part distributionassembly : DistributionAssembly {
        }
        part poweractuator : PowerActuator {
            satisfy REQ_002;
        }

        // Connections
        connect controlsubsystem.ctrlIn to distributionassembly.telemetryOut;
        connect sensorinterface.sensorOut to distributionassembly.cmdIn;
        connect distributionassembly.sensorOut to controlsubsystem.dataIn;
    }

    // System Instance
    part groundstationsystem : GroundStationSystem;

}