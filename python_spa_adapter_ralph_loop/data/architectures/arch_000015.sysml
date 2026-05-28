package arch_000015 {

    import ScalarValues::*;

    // Sensor Suite Reference Architecture 15
    // Domain: sensor suite

    // Requirements
    public requirement REQ_001 {
        doc "The sensor suite system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The sensor suite system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def CommInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port telemetryOut : TelemetryIF;
        port dataIn : StatusIF;
    }

    public part def ThermalController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut : SignalIF;
    }

    public part def SensorInterface {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut : TelemetryIF;
        port ctrlIn : StatusIF;
        port configIn : SignalIF;
    }

    public part def ThermalComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut : DataIF;
        port pwrIn : TelemetryIF;
    }

    public part def CommPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn : DiagnosticIF;
    }

    public part def FlightSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : StatusIF;
        port pwrOut : CommandIF;
        port ctrlIn : ControlIF;
    }

    // System Definition
    public part def SensorSuiteSystem {
        part comminterface : CommInterface {
        }
        part thermalcontroller : ThermalController {
            satisfy REQ_001;
        }
        part sensorinterface : SensorInterface {
        }
        part thermalcomputer : ThermalComputer {
            satisfy REQ_002;
        }
        part commpayload : CommPayload {
            satisfy REQ_002;
        }
        part flightsubsystem : FlightSubsystem {
        }

        // Connections
        connect thermalcomputer.pwrIn to sensorinterface.sensorOut;
        connect sensorinterface.ctrlIn to flightsubsystem.telemetryOut;
        connect commpayload.ctrlIn to comminterface.telemetryOut;
    }

    // System Instance
    public part sensorsuitesystem : SensorSuiteSystem;

}