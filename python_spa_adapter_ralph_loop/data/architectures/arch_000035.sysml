package arch_000035 {

    import ScalarValues::*;

    // Power Distribution System Reference Architecture 35
    // Domain: power distribution system

    // Requirements
    public requirement REQ_001 {
        doc "The power distribution system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The power distribution system system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The power distribution system system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The power distribution system system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def MonitorInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : PowerIF;
        port dataIn : DataIF;
    }

    public part def FlightActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : CommandIF;
        port pwrIn : ThermalIF;
        port cmdIn : ThermalIF;
    }

    public part def ProcessingAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : SignalIF;
    }

    public part def CommandComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : ConfigIF;
        port ctrlIn : SignalIF;
        port cmdIn : ThermalIF;
    }

    public part def ThermalSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut : CommandIF;
        port telemetryOut : ControlIF;
    }

    public part def ThermalInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : ControlIF;
        port statusOut : StatusIF;
    }

    public part def CommandInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port ctrlIn : StatusIF;
        port pwrOut : PowerIF;
        port ctrlIn : TelemetryIF;
    }

    // System Definition
    public part def PowerDistributionSystemSystem {
        part monitorinterface : MonitorInterface {
        }
        part flightactuator : FlightActuator {
            satisfy REQ_001;
        }
        part processingassembly : ProcessingAssembly {
            satisfy REQ_002;
        }
        part commandcomputer : CommandComputer {
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part thermalsensor : ThermalSensor {
            satisfy REQ_004;
        }
        part thermalinterface : ThermalInterface {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part commandinterface : CommandInterface {
        }

        // Connections
        connect commandcomputer.cmdIn to flightactuator.ctrlIn;
        connect flightactuator.ctrlIn to commandinterface.ctrlIn;
        connect processingassembly.pwrOut to thermalsensor.pwrOut;
        connect thermalsensor.pwrOut to commandinterface.pwrOut;
    }

    // System Instance
    public part powerdistributionsystemsystem : PowerDistributionSystemSystem;

}