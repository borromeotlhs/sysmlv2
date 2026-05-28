package arch_000145 {

    import ScalarValues::*;

    // Battery Management Reference Architecture 145
    // Domain: battery management

    // Requirements
    public requirement REQ_001 {
        doc "The battery management system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The battery management system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The battery management system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def ControlSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn : StatusIF;
        port pwrOut : DiagnosticIF;
    }

    public part def CommUnit {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port ctrlIn : DataIF;
    }

    public part def MissionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : ThermalIF;
        port pwrOut : TelemetryIF;
        port sensorOut : ControlIF;
    }

    public part def NavActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : SignalIF;
    }

    public part def MissionAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut : ThermalIF;
        port ctrlIn : DataIF;
    }

    // System Definition
    public part def BatteryManagementSystem {
        part controlsensor : ControlSensor {
        }
        part communit : CommUnit {
        }
        part missionbus : MissionBus {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part navactuator : NavActuator {
            satisfy REQ_003;
        }
        part missionassembly : MissionAssembly {
        }

        // Connections
        connect controlsensor.configIn to missionbus.pwrOut;
        connect navactuator.configIn to missionbus.telemetryOut;
        connect controlsensor.pwrOut to missionassembly.ctrlIn;
    }

    // System Instance
    public part batterymanagementsystem : BatteryManagementSystem;

}