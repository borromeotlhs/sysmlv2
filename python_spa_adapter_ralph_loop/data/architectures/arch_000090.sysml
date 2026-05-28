package arch_000090 {

    import ScalarValues::*;

    // Robotic Arm Reference Architecture 90
    // Domain: robotic arm

    // Requirements
    public requirement REQ_001 {
        doc "The robotic arm system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The robotic arm system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The robotic arm system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def SensorSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn : SignalIF;
    }

    public part def NavInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : ConfigIF;
    }

    public part def DistributionProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut : StatusIF;
        port pwrOut : ConfigIF;
        port cmdIn : ThermalIF;
    }

    public part def ThermalSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : PowerIF;
        port sensorOut : PowerIF;
        port ctrlIn : PowerIF;
    }

    // System Definition
    public part def RoboticArmSystem {
        part sensorsensor : SensorSensor {
            satisfy REQ_001;
        }
        part navinterface : NavInterface {
            satisfy REQ_003;
        }
        part distributionprocessor : DistributionProcessor {
            satisfy REQ_002;
        }
        part thermalsubsystem : ThermalSubsystem {
            satisfy REQ_003;
        }

        // Connections
        connect distributionprocessor.cmdOut to thermalsubsystem.ctrlIn;
        connect sensorsensor.configIn to distributionprocessor.pwrOut;
        connect distributionprocessor.pwrOut to navinterface.ctrlIn;
    }

    // System Instance
    public part roboticarmsystem : RoboticArmSystem;

}