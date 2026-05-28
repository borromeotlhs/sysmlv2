package arch_000028 {

    import ScalarValues::*;

    // Thermal Control Reference Architecture 28
    // Domain: thermal control

    // Requirements
    public requirement REQ_001 {
        doc "The thermal control system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The thermal control system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The thermal control system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;

    // Component Definitions
    public part def DistributionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : ConfigIF;
    }

    public part def ThermalAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : StatusIF;
    }

    public part def MissionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut : PowerIF;
        port pwrOut : SignalIF;
    }

    public part def CommandActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrOut : DiagnosticIF;
        port configIn : DataIF;
        port cmdIn : PowerIF;
    }

    public part def MonitorSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : CommandIF;
    }

    public part def FlightProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut : SignalIF;
        port ctrlIn : StatusIF;
        port ctrlIn : DiagnosticIF;
    }

    public part def ProcessingInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : SignalIF;
        port dataOut : ConfigIF;
    }

    // System Definition
    public part def ThermalControlSystem {
        part distributionunit : DistributionUnit {
            satisfy REQ_002;
        }
        part thermalassembly : ThermalAssembly {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part missionprocessor : MissionProcessor {
        }
        part commandactuator : CommandActuator {
        }
        part monitorsubsystem : MonitorSubsystem {
            satisfy REQ_002;
        }
        part flightprocessor : FlightProcessor {
        }
        part processinginterface : ProcessingInterface {
        }

        // Connections
        connect thermalassembly.statusOut to commandactuator.pwrOut;
        connect monitorsubsystem.configIn to flightprocessor.cmdOut;
    }

    // System Instance
    public part thermalcontrolsystem : ThermalControlSystem;

}