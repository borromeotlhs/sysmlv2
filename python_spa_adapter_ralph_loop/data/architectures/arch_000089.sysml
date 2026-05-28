package arch_000089 {

    // Ground Station Reference Architecture 89
    // Domain: ground station

    // Requirements
    public requirement REQ_001 {
        doc "The ground station system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The ground station system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def MonitorModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port configIn;
        port pwrOut;
    }

    public part def FlightUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port pwrOut;
    }

    public part def ControlController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
    }

    public part def DataAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
        port telemetryOut;
    }

    public part def NavPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn;
        port pwrOut;
    }

    public part def ThermalActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut;
        port dataIn;
    }

    public part def MonitorUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
    }

    // System Definition
    public part def GroundStationSystem {
        part monitormodule : MonitorModule {
            satisfy REQ_002;
        }
        part flightunit : FlightUnit {
        }
        part controlcontroller : ControlController {
        }
        part dataassembly : DataAssembly {
        }
        part navpayload : NavPayload {
            satisfy REQ_001;
        }
        part thermalactuator : ThermalActuator {
        }
        part monitorunit : MonitorUnit {
            satisfy REQ_001;
        }

        // Connections
        connect flightunit.pwrOut to thermalactuator.dataIn;
        connect monitormodule.configIn to thermalactuator.dataIn;
        connect monitormodule.configIn to navpayload.ctrlIn;
    }

    // System Instance
    part groundstationsystem : GroundStationSystem;

}