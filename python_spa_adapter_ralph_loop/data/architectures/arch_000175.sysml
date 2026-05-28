package arch_000175 {

    // Sensor Suite Reference Architecture 175
    // Domain: sensor suite

    // Requirements
    requirement REQ_001 {
        doc "The sensor suite system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The sensor suite system shall trace subsystem design to requirements."
    }

    // Component Definitions
    part def CommInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port telemetryOut;
        port dataIn;
    }

    part def ThermalController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut;
    }

    part def SensorInterface {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut;
        port ctrlIn;
        port configIn;
    }

    part def ThermalComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut;
        port pwrIn;
    }

    part def CommPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn;
    }

    part def FlightSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port pwrOut;
        port ctrlIn;
    }

    // System Definition
    part def SensorSuiteSystem {
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
    part sensorsuitesystem : SensorSuiteSystem;

}