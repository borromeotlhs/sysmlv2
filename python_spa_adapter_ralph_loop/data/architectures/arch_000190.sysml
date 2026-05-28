package arch_000190 {

    import ScalarValues::*;

    // Propulsion Module Reference Architecture 190
    // Domain: propulsion module

    // Requirements
    public requirement REQ_001 {
        doc "The propulsion module system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The propulsion module system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The propulsion module system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;

    // Component Definitions
    public part def SensorUnit {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataIn : DiagnosticIF;
        port ctrlIn : ControlIF;
    }

    public part def MonitorSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut : DiagnosticIF;
        port sensorOut : ConfigIF;
        port dataOut : DataIF;
    }

    // System Definition
    public part def PropulsionModuleSystem {
        part sensorunit : SensorUnit {
            satisfy REQ_003;
        }
        part monitorsensor : MonitorSensor {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect monitorsensor.pwrOut to sensorunit.ctrlIn;
        connect sensorunit.ctrlIn to monitorsensor.dataOut;
    }

    // System Instance
    public part propulsionmodulesystem : PropulsionModuleSystem;

}