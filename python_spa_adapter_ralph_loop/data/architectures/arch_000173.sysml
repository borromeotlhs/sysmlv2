package arch_000173 {

    import ScalarValues::*;

    // Avionics Bay Reference Architecture 173
    // Domain: avionics bay

    // Requirements
    public requirement REQ_001 {
        doc "The avionics bay system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The avionics bay system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def DiagnosticIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def SensorSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataOut : ControlIF;
        port dataOut : ControlIF;
        port pwrIn : SignalIF;
    }

    public part def MonitorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : SignalIF;
        port dataOut : DiagnosticIF;
        port dataIn : ConfigIF;
    }

    public part def DistributionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn : SignalIF;
        port pwrIn : ControlIF;
    }

    public part def DataController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : DiagnosticIF;
        port telemetryOut : CommandIF;
    }

    public part def FlightController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : ConfigIF;
        port dataIn : StatusIF;
    }

    public part def ThermalComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut : ThermalIF;
    }

    // System Definition
    public part def AvionicsBaySystem {
        part sensorsensor : SensorSensor {
        }
        part monitorcontroller : MonitorController {
        }
        part distributionunit : DistributionUnit {
            satisfy REQ_002;
        }
        part datacontroller : DataController {
            satisfy REQ_001;
        }
        part flightcontroller : FlightController {
            satisfy REQ_001;
        }
        part thermalcomputer : ThermalComputer {
        }

        // Connections
        connect monitorcontroller.telemetryOut to datacontroller.statusOut;
        connect thermalcomputer.dataOut to datacontroller.statusOut;
        connect flightcontroller.dataIn to distributionunit.pwrIn;
        connect thermalcomputer.dataOut to sensorsensor.dataOut;
        connect monitorcontroller.telemetryOut to distributionunit.cmdIn;
    }

    // System Instance
    public part avionicsbaysystem : AvionicsBaySystem;

}