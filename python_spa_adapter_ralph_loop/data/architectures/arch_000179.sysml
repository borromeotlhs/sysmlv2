package arch_000179 {

    import ScalarValues::*;

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

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def SensorActuator {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut : ControlIF;
    }

    public part def CommandUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port ctrlIn : DataIF;
        port pwrOut : CommandIF;
        port configIn : DiagnosticIF;
    }

    public part def FlightActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : ConfigIF;
        port telemetryOut : ThermalIF;
    }

    public part def ThermalInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : CommandIF;
        port dataOut : CommandIF;
        port configIn : DataIF;
    }

    public part def ProcessingSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : StatusIF;
        port dataOut : DiagnosticIF;
    }

    public part def MonitorBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn : PowerIF;
    }

    public part def CommandAssembly {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port ctrlIn : SignalIF;
        port dataOut : PowerIF;
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
    public part satellitebussystem : SatelliteBusSystem;

}