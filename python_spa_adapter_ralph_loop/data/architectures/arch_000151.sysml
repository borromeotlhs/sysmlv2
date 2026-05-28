package arch_000151 {

    // Propulsion Module Reference Architecture 151
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

    // Component Definitions
    public part def DataActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
        port ctrlIn;
    }

    public part def NavModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
        port statusOut;
    }

    public part def ThermalActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port cmdOut;
        port sensorOut;
    }

    public part def MonitorInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
    }

    // System Definition
    public part def PropulsionModuleSystem {
        part dataactuator : DataActuator {
        }
        part navmodule : NavModule {
            satisfy REQ_003;
        }
        part thermalactuator : ThermalActuator {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part monitorinterface : MonitorInterface {
        }

        // Connections
        connect thermalactuator.cmdOut to dataactuator.cmdOut;
        connect thermalactuator.cmdOut to navmodule.statusOut;
        connect dataactuator.cmdOut to navmodule.statusOut;
        connect navmodule.statusOut to monitorinterface.pwrOut;
        connect dataactuator.ctrlIn to thermalactuator.cmdOut;
    }

    // System Instance
    part propulsionmodulesystem : PropulsionModuleSystem;

}