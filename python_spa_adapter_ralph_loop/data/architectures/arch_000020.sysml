package arch_000020 {

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

    // Component Definitions
    public part def CommandUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port sensorOut;
        port sensorOut;
    }

    public part def NavBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
    }

    public part def NavController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut;
        port ctrlIn;
    }

    public part def MissionInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
        port ctrlIn;
        port dataOut;
    }

    public part def ControlModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port dataOut;
        port sensorOut;
    }

    public part def ProcessingProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
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
    part thermalcontrolsystem : ThermalControlSystem;

}