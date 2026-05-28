package arch_000121 {

    // Attitude Control Reference Architecture 121
    // Domain: attitude control

    // Requirements
    public requirement REQ_001 {
        doc "The attitude control system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The attitude control system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def NavController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn;
    }

    public part def ControlActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port pwrOut;
        port telemetryOut;
    }

    public part def NavAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
    }

    public part def SensorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut;
        port dataIn;
        port ctrlIn;
    }

    public part def NavProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut;
        port configIn;
    }

    public part def PowerSubsystem {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port dataOut;
    }

    // System Definition
    public part def AttitudeControlSystem {
        part navcontroller : NavController {
            satisfy REQ_002;
        }
        part controlactuator : ControlActuator {
        }
        part navassembly : NavAssembly {
            satisfy REQ_002;
        }
        part sensorcontroller : SensorController {
        }
        part navprocessor : NavProcessor {
        }
        part powersubsystem : PowerSubsystem {
            satisfy REQ_001;
        }

        // Connections
        connect navprocessor.configIn to powersubsystem.dataOut;
        connect controlactuator.configIn to navprocessor.configIn;
        connect sensorcontroller.dataIn to controlactuator.pwrOut;
        connect navcontroller.configIn to sensorcontroller.telemetryOut;
    }

    // System Instance
    part attitudecontrolsystem : AttitudeControlSystem;

}