package arch_000024 {

    // Robotic Arm Reference Architecture 24
    // Domain: robotic arm

    // Requirements
    requirement REQ_001 {
        doc "The robotic arm system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The robotic arm system shall trace subsystem design to requirements."
    }

    requirement REQ_003 {
        doc "The robotic arm system shall provide fault detection and recovery."
    }

    // Component Definitions
    part def ControlModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port statusOut;
        port dataIn;
        port cmdIn;
    }

    part def MonitorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut;
        port dataOut;
    }

    part def MonitorPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port statusOut;
    }

    part def ProcessingUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
        port statusOut;
    }

    // System Definition
    part def RoboticArmSystem {
        part controlmodule : ControlModule {
            satisfy REQ_003;
        }
        part monitorcontroller : MonitorController {
            satisfy REQ_003;
        }
        part monitorpayload : MonitorPayload {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part processingunit : ProcessingUnit {
        }

        // Connections
        connect processingunit.telemetryOut to controlmodule.dataIn;
        connect processingunit.telemetryOut to monitorcontroller.dataOut;
        connect monitorpayload.statusOut to monitorcontroller.cmdOut;
    }

    // System Instance
    part roboticarmsystem : RoboticArmSystem;

}