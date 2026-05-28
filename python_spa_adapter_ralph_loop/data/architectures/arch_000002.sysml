package arch_000002 {

    // Avionics Bay Reference Architecture 2
    // Domain: avionics bay

    // Requirements
    requirement REQ_001 {
        doc "The avionics bay system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The avionics bay system shall trace subsystem design to requirements."
    }

    requirement REQ_003 {
        doc "The avionics bay system shall provide fault detection and recovery."
    }

    // Component Definitions
    part def ControlAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port dataIn;
    }

    part def ControlModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
        port telemetryOut;
    }

    part def ProcessingController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
        port sensorOut;
        port dataIn;
    }

    part def MissionInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
        port dataOut;
    }

    part def DataUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
    }

    part def FlightModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
        port cmdOut;
    }

    part def FlightSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
        port telemetryOut;
        port statusOut;
    }

    // System Definition
    part def AvionicsBaySystem {
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
    part avionicsbaysystem : AvionicsBaySystem;

}