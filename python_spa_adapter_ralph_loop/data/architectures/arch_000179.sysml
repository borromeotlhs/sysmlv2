package arch_000179 {

    // Satellite Bus Reference Architecture 179
    // Domain: satellite bus

    // Requirements
    public requirement REQ_001 {
        doc "The satellite bus system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The satellite bus system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The satellite bus system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The satellite bus system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def SensorActuator {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut;
    }

    public part def CommandUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port ctrlIn;
        port pwrOut;
        port configIn;
    }

    public part def FlightActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
        port telemetryOut;
    }

    public part def ThermalInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port dataOut;
        port configIn;
    }

    public part def ProcessingSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
        port dataOut;
    }

    public part def MonitorBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
    }

    public part def CommandAssembly {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port ctrlIn;
        port dataOut;
    }

    // System Definition
    public part def SatelliteBusSystem {
        part sensoractuator : SensorActuator {
        }
        part commandunit : CommandUnit {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part flightactuator : FlightActuator {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part thermalinterface : ThermalInterface {
        }
        part processingsubsystem : ProcessingSubsystem {
            satisfy REQ_004;
        }
        part monitorbus : MonitorBus {
            satisfy REQ_001;
        }
        part commandassembly : CommandAssembly {
        }

        // Connections
        connect commandunit.configIn to processingsubsystem.dataOut;
        connect commandunit.configIn to monitorbus.cmdIn;
        connect thermalinterface.dataOut to monitorbus.cmdIn;
        connect commandunit.pwrOut to flightactuator.statusOut;
        connect processingsubsystem.dataOut to commandassembly.ctrlIn;
    }

    // System Instance
    part satellitebussystem : SatelliteBusSystem;

}