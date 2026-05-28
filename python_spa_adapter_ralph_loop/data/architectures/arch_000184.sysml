package arch_000184 {

    import ScalarValues::*;

    // Solar Array Reference Architecture 184
    // Domain: solar array

    // Requirements
    public requirement REQ_001 {
        doc "The solar array system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The solar array system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : DataIF;
        port cmdIn : CommandIF;
    }

    public part def CommandController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdIn : DiagnosticIF;
        port cmdIn : DataIF;
    }

    public part def PowerController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut : CommandIF;
    }

    public part def CommController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn : ConfigIF;
        port pwrIn : TelemetryIF;
    }

    public part def ThermalComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut : DiagnosticIF;
        port statusOut : ControlIF;
    }

    public part def ControlModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : ControlIF;
        port pwrOut : ThermalIF;
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
    public part solararraysystem : SolarArraySystem;

}