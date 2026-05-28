package arch_000080 {

    import ScalarValues::*;

    // Attitude Control Reference Architecture 80
    // Domain: attitude control

    // Requirements
    public requirement REQ_001 {
        doc "The attitude control system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The attitude control system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The attitude control system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def DataIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def CommPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrIn : TelemetryIF;
        port dataIn : ThermalIF;
        port telemetryOut : CommandIF;
    }

    public part def CommController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : DataIF;
        port telemetryOut : ConfigIF;
    }

    // System Definition
    public part def AttitudeControlSystem {
        part commpayload : CommPayload {
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part commcontroller : CommController {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect commpayload.dataIn to commcontroller.statusOut;
        connect commcontroller.telemetryOut to commpayload.dataIn;
        connect commpayload.telemetryOut to commcontroller.statusOut;
        connect commcontroller.telemetryOut to commpayload.pwrIn;
    }

    // System Instance
    public part attitudecontrolsystem : AttitudeControlSystem;

}