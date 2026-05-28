package arch_000002 {

    import ScalarValues::*;

    // Avionics Bay Reference Architecture 2
    // Domain: avionics bay

    // Requirements
    public requirement REQ_001 {
        doc "The avionics bay system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The avionics bay system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The avionics bay system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def ControlAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : ControlIF;
        port dataIn : ControlIF;
    }

    public part def ControlModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : SignalIF;
        port telemetryOut : DataIF;
    }

    public part def ProcessingController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : PowerIF;
        port sensorOut : ThermalIF;
        port dataIn : TelemetryIF;
    }

    public part def MissionInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : ConfigIF;
        port dataOut : ControlIF;
    }

    public part def DataUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : CommandIF;
    }

    public part def FlightModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : SignalIF;
        port cmdOut : ThermalIF;
    }

    public part def FlightSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : ThermalIF;
        port telemetryOut : TelemetryIF;
        port statusOut : TelemetryIF;
    }

    // System Definition
    public part def AvionicsBaySystem {
        part controlassembly : ControlAssembly {
            satisfy REQ_003;
        }
        part controlmodule : ControlModule {
            satisfy REQ_001;
        }
        part processingcontroller : ProcessingController {
            satisfy REQ_001;
        }
        part missioninterface : MissionInterface {
        }
        part dataunit : DataUnit {
            satisfy REQ_002;
        }
        part flightmodule : FlightModule {
        }
        part flightsubsystem : FlightSubsystem {
            satisfy REQ_003;
        }

        // Connections
        connect processingcontroller.telemetryOut to controlmodule.dataOut;
        connect flightmodule.cmdOut to missioninterface.dataOut;
        connect processingcontroller.telemetryOut to flightmodule.cmdOut;
    }

    // System Instance
    public part avionicsbaysystem : AvionicsBaySystem;

}