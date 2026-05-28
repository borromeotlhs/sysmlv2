package arch_000173 {

    // Avionics Bay Reference Architecture 173
    // Domain: avionics bay

    // Requirements
    public requirement REQ_001 {
        doc "The avionics bay system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The avionics bay system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def SensorSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataOut;
        port dataOut;
        port pwrIn;
    }

    public part def MonitorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
        port dataOut;
        port dataIn;
    }

    public part def DistributionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
        port pwrIn;
    }

    public part def DataController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
        port telemetryOut;
    }

    public part def FlightController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
        port dataIn;
    }

    public part def ThermalComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut;
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
    part avionicsbaysystem : AvionicsBaySystem;

}