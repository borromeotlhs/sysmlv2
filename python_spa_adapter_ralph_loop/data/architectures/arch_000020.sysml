package arch_000020 {

    import ScalarValues::*;

    // Thermal Control Reference Architecture 20
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
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def CommandUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port sensorOut : CommandIF;
        port sensorOut : StatusIF;
    }

    public part def NavBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : DataIF;
    }

    public part def NavController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut : PowerIF;
        port ctrlIn : SignalIF;
    }

    public part def MissionInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : StatusIF;
        port ctrlIn : TelemetryIF;
        port dataOut : TelemetryIF;
    }

    public part def ControlModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : StatusIF;
        port dataOut : DiagnosticIF;
        port sensorOut : PowerIF;
    }

    public part def ProcessingProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn : StatusIF;
    }

    // System Definition
    public part def ThermalControlSystem {
        part commandunit : CommandUnit {
        }
        part navbus : NavBus {
        }
        part navcontroller : NavController {
            satisfy REQ_002;
        }
        part missioninterface : MissionInterface {
            satisfy REQ_002;
        }
        part controlmodule : ControlModule {
            satisfy REQ_001;
        }
        part processingprocessor : ProcessingProcessor {
            satisfy REQ_001;
            satisfy REQ_003;
        }

        // Connections
        connect controlmodule.dataIn to navcontroller.ctrlIn;
        connect navcontroller.ctrlIn to processingprocessor.pwrIn;
        connect controlmodule.sensorOut to missioninterface.dataOut;
        connect missioninterface.dataOut to controlmodule.dataIn;
    }

    // System Instance
    public part thermalcontrolsystem : ThermalControlSystem;

}