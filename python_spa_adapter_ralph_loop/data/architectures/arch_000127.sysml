package arch_000127 {

    // Lunar Habitat Reference Architecture 127
    // Domain: lunar habitat

    // Requirements
    requirement REQ_001 {
        doc "The lunar habitat system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The lunar habitat system shall trace subsystem design to requirements."
    }

    // Component Definitions
    part def MonitorActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
    }

    part def ControlSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut;
    }

    part def ThermalUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
        port cmdIn;
    }

    part def DataInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port cmdOut;
        port dataOut;
    }

    part def ProcessingAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port cmdOut;
    }

    // System Definition
    part def LunarHabitatSystem {
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