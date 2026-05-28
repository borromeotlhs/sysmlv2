package arch_000194 {

    import ScalarValues::*;

    // Command Data Handling Reference Architecture 194
    // Domain: command data handling

    // Requirements
    public requirement REQ_001 {
        doc "The command data handling system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The command data handling system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;

    // Component Definitions
    public part def MissionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : DataIF;
    }

    public part def CommPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdIn : PowerIF;
        port telemetryOut : SignalIF;
    }

    public part def DataController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port ctrlIn : StatusIF;
    }

    public part def SensorSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn : ControlIF;
        port statusOut : PowerIF;
    }

    // System Definition
    public part def CommandDataHandlingSystem {
        part missioncontroller : MissionController {
        }
        part commpayload : CommPayload {
            satisfy REQ_002;
        }
        part datacontroller : DataController {
            satisfy REQ_001;
        }
        part sensorsensor : SensorSensor {
        }

        // Connections
        connect missioncontroller.statusOut to datacontroller.ctrlIn;
        connect datacontroller.ctrlIn to commpayload.cmdIn;
        connect commpayload.telemetryOut to sensorsensor.statusOut;
        connect missioncontroller.statusOut to commpayload.telemetryOut;
    }

    // System Instance
    public part commanddatahandlingsystem : CommandDataHandlingSystem;

}