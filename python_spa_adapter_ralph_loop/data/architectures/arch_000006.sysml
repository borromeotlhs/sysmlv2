package arch_000006 {

    // Thermal Control Reference Architecture 6
    // Domain: thermal control

    // Requirements
    public requirement REQ_001 {
        doc "The thermal control system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The thermal control system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def PowerSubsystem {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port pwrIn;
    }

    public part def ProcessingBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
    }

    public part def DistributionSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut;
    }

    public part def MonitorBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
    }

    public part def NavProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut;
        port cmdIn;
        port cmdOut;
    }

    // System Definition
    public part def ThermalControlSystem {
        part powersubsystem : PowerSubsystem {
        }
        part processingbus : ProcessingBus {
        }
        part distributionsensor : DistributionSensor {
        }
        part monitorbus : MonitorBus {
        }
        part navprocessor : NavProcessor {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect navprocessor.sensorOut to powersubsystem.pwrIn;
        connect navprocessor.cmdOut to processingbus.configIn;
    }

    // System Instance
    part thermalcontrolsystem : ThermalControlSystem;

}