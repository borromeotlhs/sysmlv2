package arch_000108 {

    // Telemetry System Reference Architecture 108
    // Domain: telemetry system

    // Requirements
    public requirement REQ_001 {
        doc "The telemetry system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The telemetry system system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The telemetry system system shall provide fault detection and recovery."
    }

    // Component Definitions
    public part def DistributionSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
        port statusOut;
        port cmdOut;
    }

    public part def CommandProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
        port dataIn;
        port sensorOut;
    }

    public part def ThermalController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
        port dataOut;
    }

    public part def NavActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut;
        port dataOut;
        port pwrIn;
    }

    // System Definition
    public part def TelemetrySystemSystem {
        part distributionsubsystem : DistributionSubsystem {
            satisfy REQ_003;
        }
        part commandprocessor : CommandProcessor {
            satisfy REQ_001;
        }
        part thermalcontroller : ThermalController {
            satisfy REQ_002;
        }
        part navactuator : NavActuator {
        }

        // Connections
        connect navactuator.pwrIn to thermalcontroller.statusOut;
        connect commandprocessor.sensorOut to navactuator.dataOut;
        connect distributionsubsystem.cmdIn to commandprocessor.dataIn;
        connect thermalcontroller.dataOut to navactuator.dataOut;
    }

    // System Instance
    part telemetrysystemsystem : TelemetrySystemSystem;

}