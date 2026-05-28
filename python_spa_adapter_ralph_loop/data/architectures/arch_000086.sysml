package arch_000086 {

    import ScalarValues::*;

    // Sensor Suite Reference Architecture 86
    // Domain: sensor suite

    // Requirements
    public requirement REQ_001 {
        doc "The sensor suite system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The sensor suite system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The sensor suite system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The sensor suite system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def DiagnosticIF;
    public port def ThermalIF;

    // Component Definitions
    public part def DataInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : ConfigIF;
    }

    public part def ThermalAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut : CommandIF;
        port cmdOut : ControlIF;
    }

    public part def ThermalUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : DiagnosticIF;
        port configIn : ThermalIF;
    }

    // System Definition
    public part def SensorSuiteSystem {
        part datainterface : DataInterface {
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part thermalassembly : ThermalAssembly {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part thermalunit : ThermalUnit {
            satisfy REQ_001;
        }

        // Connections
        connect thermalassembly.cmdOut to thermalunit.dataOut;
        connect thermalunit.configIn to thermalassembly.cmdOut;
    }

    // System Instance
    public part sensorsuitesystem : SensorSuiteSystem;

}