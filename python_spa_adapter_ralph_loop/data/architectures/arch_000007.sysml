package arch_000007 {

    // Lunar Habitat Reference Architecture 7
    // Domain: lunar habitat

    // Requirements
    public requirement REQ_001 {
        doc "The lunar habitat system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The lunar habitat system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def MonitorActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
    }

    public part def ControlSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut;
    }

    public part def ThermalUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
        port cmdIn;
    }

    public part def DataInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port cmdOut;
        port dataOut;
    }

    public part def ProcessingAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port cmdOut;
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
    part lunarhabitatsystem : LunarHabitatSystem;

}