package arch_000139 {

    import ScalarValues::*;

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

    // Port Definitions
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def ThermalIF;

    // Component Definitions
    public part def ThermalActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn : SignalIF;
        port dataIn : DiagnosticIF;
        port cmdIn : PowerIF;
    }

    public part def NavActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : PowerIF;
        port pwrOut : PowerIF;
    }

    public part def CommUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrIn : ControlIF;
    }

    public part def MonitorInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : ControlIF;
        port cmdIn : SignalIF;
    }

    public part def NavBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut : DataIF;
        port sensorOut : ThermalIF;
    }

    public part def FlightAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : DataIF;
        port configIn : PowerIF;
        port sensorOut : ControlIF;
    }

    public part def SensorBus {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut : SignalIF;
        port pwrIn : ControlIF;
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
    public part lifesupportsystem : LifeSupportSystem;

}