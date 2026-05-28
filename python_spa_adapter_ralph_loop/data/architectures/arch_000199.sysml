package arch_000199 {

    import ScalarValues::*;

    // Attitude Control Reference Architecture 199
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
    public port def PowerIF;
    public port def SignalIF;
    public port def ThermalIF;

    // Component Definitions
    public part def DistributionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut : SignalIF;
        port pwrIn : ThermalIF;
        port pwrIn : SignalIF;
    }

    public part def NavSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut : PowerIF;
        port dataOut : CommandIF;
        port sensorOut : ThermalIF;
    }

    // System Definition
    public part def AttitudeControlSystem {
        part distributionsensor : DistributionSensor {
            satisfy REQ_001;
        }
        part navsensor : NavSensor {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }

        // Connections
        connect distributionsensor.sensorOut to navsensor.sensorOut;
        connect navsensor.sensorOut to distributionsensor.pwrIn;
        connect navsensor.dataOut to distributionsensor.sensorOut;
        connect navsensor.dataOut to distributionsensor.pwrIn;
    }

    // System Instance
    public part attitudecontrolsystem : AttitudeControlSystem;

}