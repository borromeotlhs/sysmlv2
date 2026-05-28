package arch_000104 {

    // Docking Mechanism Reference Architecture 104
    // Domain: docking mechanism

    // Requirements
    public requirement REQ_001 {
        doc "The docking mechanism system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The docking mechanism system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def SensorAssembly {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port sensorOut;
        port cmdOut;
        port dataIn;
    }

    public part def ThermalBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn;
        port pwrOut;
    }

    public part def NavUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
    }

    // System Definition
    public part def DockingMechanismSystem {
        part sensorassembly : SensorAssembly {
            satisfy REQ_002;
        }
        part thermalbus : ThermalBus {
        }
        part navunit : NavUnit {
            satisfy REQ_001;
        }

        // Connections
        connect navunit.telemetryOut to sensorassembly.cmdOut;
        connect thermalbus.pwrOut to sensorassembly.dataIn;
        connect navunit.telemetryOut to sensorassembly.sensorOut;
        connect sensorassembly.cmdOut to thermalbus.pwrOut;
        connect thermalbus.pwrIn to navunit.telemetryOut;
    }

    // System Instance
    part dockingmechanismsystem : DockingMechanismSystem;

}