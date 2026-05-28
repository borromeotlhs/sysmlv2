package arch_000193 {

    // Uav Payload Reference Architecture 193
    // Domain: uav payload

    // Requirements
    public requirement REQ_001 {
        doc "The uav payload system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The uav payload system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The uav payload system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def DataBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port cmdIn;
        port ctrlIn;
    }

    public part def MissionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut;
        port dataIn;
        port pwrOut;
    }

    public part def CommBus {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrOut;
        port statusOut;
        port statusOut;
    }

    public part def SensorBus {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut;
        port telemetryOut;
    }

    public part def ThermalModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
        port pwrIn;
        port pwrIn;
    }

    public part def ProcessingInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
    }

    // System Definition
    public part def UavPayloadSystem {
        part databus : DataBus {
            satisfy REQ_002;
        }
        part missionbus : MissionBus {
            satisfy REQ_003;
        }
        part commbus : CommBus {
            satisfy REQ_001;
        }
        part sensorbus : SensorBus {
        }
        part thermalmodule : ThermalModule {
        }
        part processinginterface : ProcessingInterface {
            satisfy REQ_001;
            satisfy REQ_003;
        }

        // Connections
        connect missionbus.sensorOut to processinginterface.cmdIn;
        connect sensorbus.telemetryOut to commbus.statusOut;
        connect processinginterface.cmdIn to commbus.statusOut;
        connect thermalmodule.pwrIn to commbus.statusOut;
        connect missionbus.pwrOut to databus.telemetryOut;
    }

    // System Instance
    part uavpayloadsystem : UavPayloadSystem;

}