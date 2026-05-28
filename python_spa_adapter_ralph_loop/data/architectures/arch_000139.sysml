package arch_000139 {

    // Life Support Reference Architecture 139
    // Domain: life support

    // Requirements
    public requirement REQ_001 {
        doc "The life support system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The life support system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The life support system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def ThermalActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
        port dataIn;
        port cmdIn;
    }

    public part def NavActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port pwrOut;
    }

    public part def CommUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrIn;
    }

    public part def MonitorInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port cmdIn;
    }

    public part def NavBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut;
        port sensorOut;
    }

    public part def FlightAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port configIn;
        port sensorOut;
    }

    public part def SensorBus {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut;
        port pwrIn;
    }

    // System Definition
    public part def LifeSupportSystem {
        part thermalactuator : ThermalActuator {
        }
        part navactuator : NavActuator {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part communit : CommUnit {
            satisfy REQ_001;
        }
        part monitorinterface : MonitorInterface {
        }
        part navbus : NavBus {
            satisfy REQ_003;
        }
        part flightassembly : FlightAssembly {
        }
        part sensorbus : SensorBus {
        }

        // Connections
        connect communit.pwrIn to sensorbus.telemetryOut;
        connect navbus.sensorOut to navactuator.pwrOut;
    }

    // System Instance
    part lifesupportsystem : LifeSupportSystem;

}