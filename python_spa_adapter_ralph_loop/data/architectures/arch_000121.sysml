package arch_000121 {

    import ScalarValues::*;

    // Attitude Control Reference Architecture 121
    // Domain: attitude control

    // Requirements
    public requirement REQ_001 {
        doc "The attitude control system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The attitude control system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def StatusIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def NavController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn : DataIF;
    }

    public part def ControlActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn : StatusIF;
        port pwrOut : TelemetryIF;
        port telemetryOut : CommandIF;
    }

    public part def NavAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : PowerIF;
    }

    public part def SensorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : CommandIF;
        port dataIn : PowerIF;
        port ctrlIn : ConfigIF;
    }

    public part def NavProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port statusOut : DiagnosticIF;
        port configIn : TelemetryIF;
    }

    public part def PowerSubsystem {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port dataOut : ControlIF;
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
    public part attitudecontrolsystem : AttitudeControlSystem;

}