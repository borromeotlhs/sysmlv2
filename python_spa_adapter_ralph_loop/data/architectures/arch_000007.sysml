package arch_000007 {

    import ScalarValues::*;

    // Lunar Habitat Reference Architecture 7
    // Domain: lunar habitat

    // Requirements
    public requirement REQ_001 {
        doc "The lunar habitat system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The lunar habitat system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def MonitorActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : StatusIF;
    }

    public part def ControlSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut : SignalIF;
    }

    public part def ThermalUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : DataIF;
        port cmdIn : TelemetryIF;
    }

    public part def DataInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : DataIF;
        port cmdOut : ConfigIF;
        port dataOut : ConfigIF;
    }

    public part def ProcessingAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : ControlIF;
        port cmdOut : ThermalIF;
    }

    // System Definition
    public part def LunarHabitatSystem {
        part monitoractuator : MonitorActuator {
        }
        part controlsensor : ControlSensor {
        }
        part thermalunit : ThermalUnit {
            satisfy REQ_002;
        }
        part datainterface : DataInterface {
        }
        part processingassembly : ProcessingAssembly {
            satisfy REQ_001;
        }

        // Connections
        connect datainterface.configIn to thermalunit.pwrOut;
        connect processingassembly.cmdOut to datainterface.configIn;
        connect processingassembly.cmdOut to monitoractuator.pwrIn;
        connect controlsensor.telemetryOut to thermalunit.pwrOut;
    }

    // System Instance
    public part lunarhabitatsystem : LunarHabitatSystem;

}