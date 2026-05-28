package arch_000174 {

    import ScalarValues::*;

    // Ground Station Reference Architecture 174
    // Domain: ground station

    // Requirements
    public requirement REQ_001 {
        doc "The ground station system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The ground station system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The ground station system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def CommandUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port sensorOut : SignalIF;
        port pwrOut : DiagnosticIF;
    }

    public part def ProcessingComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn : CommandIF;
    }

    public part def NavInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : ControlIF;
    }

    public part def ThermalAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : DiagnosticIF;
        port configIn : DiagnosticIF;
        port statusOut : StatusIF;
    }

    public part def DataSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : DataIF;
    }

    public part def CommInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port statusOut : ThermalIF;
        port ctrlIn : DataIF;
        port pwrOut : DiagnosticIF;
    }

    // System Definition
    public part def GroundStationSystem {
        part commandunit : CommandUnit {
        }
        part processingcomputer : ProcessingComputer {
            satisfy REQ_001;
        }
        part navinterface : NavInterface {
        }
        part thermalassembly : ThermalAssembly {
            satisfy REQ_003;
        }
        part datasubsystem : DataSubsystem {
            satisfy REQ_002;
        }
        part comminterface : CommInterface {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect comminterface.pwrOut to thermalassembly.telemetryOut;
        connect processingcomputer.configIn to commandunit.pwrOut;
        connect comminterface.statusOut to processingcomputer.configIn;
        connect comminterface.ctrlIn to datasubsystem.statusOut;
        connect processingcomputer.configIn to navinterface.dataIn;
    }

    // System Instance
    public part groundstationsystem : GroundStationSystem;

}