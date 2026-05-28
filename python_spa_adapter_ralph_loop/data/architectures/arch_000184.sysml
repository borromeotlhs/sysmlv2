package arch_000184 {

    // Solar Array Reference Architecture 184
    // Domain: solar array

    // Requirements
    public requirement REQ_001 {
        doc "The solar array system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The solar array system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port cmdIn;
    }

    public part def CommandController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn;
        port cmdIn;
    }

    public part def PowerController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut;
    }

    public part def CommController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn;
        port pwrIn;
    }

    public part def ThermalComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut;
        port statusOut;
    }

    public part def ControlModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port pwrOut;
    }

    // System Definition
    public part def SolarArraySystem {
        part flightinterface : FlightInterface {
        }
        part commandcontroller : CommandController {
            satisfy REQ_002;
        }
        part powercontroller : PowerController {
        }
        part commcontroller : CommController {
        }
        part thermalcomputer : ThermalComputer {
            satisfy REQ_001;
        }
        part controlmodule : ControlModule {
            satisfy REQ_002;
        }

        // Connections
        connect controlmodule.pwrOut to commcontroller.pwrIn;
        connect controlmodule.telemetryOut to flightinterface.ctrlIn;
        connect commcontroller.configIn to flightinterface.cmdIn;
        connect thermalcomputer.pwrOut to commcontroller.pwrIn;
    }

    // System Instance
    part solararraysystem : SolarArraySystem;

}