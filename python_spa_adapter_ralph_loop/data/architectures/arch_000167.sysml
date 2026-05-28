package arch_000167 {

    import ScalarValues::*;

    // Solar Array Reference Architecture 167
    // Domain: solar array

    // Requirements
    public requirement REQ_001 {
        doc "The solar array system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The solar array system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The solar array system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The solar array system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def MonitorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut : CommandIF;
        port pwrIn : StatusIF;
        port sensorOut : TelemetryIF;
    }

    public part def ThermalSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn : StatusIF;
        port dataOut : ControlIF;
    }

    public part def CommUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port configIn : CommandIF;
    }

    public part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : StatusIF;
        port cmdOut : ThermalIF;
        port dataOut : PowerIF;
    }

    public part def SensorPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn : DataIF;
        port telemetryOut : DataIF;
    }

    public part def NavAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : StatusIF;
    }

    public part def SensorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn : ControlIF;
    }

    // System Definition
    public part def SolarArraySystem {
        part monitorcomputer : MonitorComputer {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part thermalsubsystem : ThermalSubsystem {
        }
        part communit : CommUnit {
        }
        part flightinterface : FlightInterface {
            satisfy REQ_004;
        }
        part sensorpayload : SensorPayload {
            satisfy REQ_002;
        }
        part navassembly : NavAssembly {
        }
        part sensorcomputer : SensorComputer {
            satisfy REQ_001;
        }

        // Connections
        connect thermalsubsystem.cmdIn to monitorcomputer.pwrIn;
        connect thermalsubsystem.cmdIn to communit.configIn;
        connect communit.configIn to flightinterface.dataOut;
        connect monitorcomputer.pwrIn to sensorcomputer.configIn;
    }

    // System Instance
    public part solararraysystem : SolarArraySystem;

}