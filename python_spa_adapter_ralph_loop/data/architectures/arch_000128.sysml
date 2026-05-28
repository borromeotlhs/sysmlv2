package arch_000128 {

    import ScalarValues::*;

    // Fuel Cell Reference Architecture 128
    // Domain: fuel cell

    // Requirements
    public requirement REQ_001 {
        doc "The fuel cell system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The fuel cell system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The fuel cell system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The fuel cell system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def MonitorSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdIn : TelemetryIF;
        port configIn : CommandIF;
        port dataOut : PowerIF;
    }

    public part def NavInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : CommandIF;
    }

    public part def SensorProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut : TelemetryIF;
        port configIn : PowerIF;
    }

    public part def ProcessingActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : DataIF;
        port cmdOut : TelemetryIF;
        port configIn : DiagnosticIF;
    }

    public part def DataController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut : ThermalIF;
    }

    public part def MissionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : StatusIF;
        port pwrOut : DataIF;
    }

    public part def CommandPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn : ConfigIF;
        port dataIn : ControlIF;
        port dataOut : CommandIF;
    }

    // System Definition
    public part def FuelCellSystem {
        part monitorsensor : MonitorSensor {
        }
        part navinterface : NavInterface {
            satisfy REQ_003;
        }
        part sensorprocessor : SensorProcessor {
        }
        part processingactuator : ProcessingActuator {
            satisfy REQ_001;
        }
        part datacontroller : DataController {
            satisfy REQ_002;
        }
        part missionbus : MissionBus {
        }
        part commandpayload : CommandPayload {
            satisfy REQ_004;
        }

        // Connections
        connect sensorprocessor.configIn to monitorsensor.configIn;
        connect sensorprocessor.cmdOut to monitorsensor.dataOut;
        connect monitorsensor.dataOut to missionbus.pwrOut;
    }

    // System Instance
    public part fuelcellsystem : FuelCellSystem;

}