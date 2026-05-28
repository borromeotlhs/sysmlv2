package arch_000186 {

    import ScalarValues::*;

    // Battery Management Reference Architecture 186
    // Domain: battery management

    // Requirements
    public requirement REQ_001 {
        doc "The battery management system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The battery management system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The battery management system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The battery management system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def MonitorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut : DiagnosticIF;
        port configIn : DataIF;
    }

    public part def MonitorProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut : StatusIF;
        port statusOut : ConfigIF;
        port statusOut : ThermalIF;
    }

    public part def SensorInterface {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn : DataIF;
    }

    public part def ProcessingPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut : DataIF;
        port cmdOut : ControlIF;
    }

    public part def FlightBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : ThermalIF;
        port cmdOut : DiagnosticIF;
        port pwrOut : PowerIF;
    }

    // System Definition
    public part def BatteryManagementSystem {
        part monitorcontroller : MonitorController {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part monitorprocessor : MonitorProcessor {
            satisfy REQ_004;
        }
        part sensorinterface : SensorInterface {
            satisfy REQ_004;
        }
        part processingpayload : ProcessingPayload {
            satisfy REQ_003;
        }
        part flightbus : FlightBus {
            satisfy REQ_001;
        }

        // Connections
        connect processingpayload.cmdOut to flightbus.cmdOut;
        connect monitorprocessor.statusOut to monitorcontroller.dataOut;
        connect flightbus.configIn to monitorprocessor.statusOut;
        connect processingpayload.cmdOut to sensorinterface.pwrIn;
    }

    // System Instance
    public part batterymanagementsystem : BatteryManagementSystem;

}