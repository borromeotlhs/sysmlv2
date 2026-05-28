package arch_000047 {

    import ScalarValues::*;

    // Power Distribution System Reference Architecture 47
    // Domain: power distribution system

    // Requirements
    public requirement REQ_001 {
        doc "The power distribution system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The power distribution system system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The power distribution system system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def DiagnosticIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def ThermalProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut : ThermalIF;
    }

    public part def PowerModule {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port cmdOut : DiagnosticIF;
    }

    public part def ProcessingController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port ctrlIn : DiagnosticIF;
    }

    public part def MissionInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn : ThermalIF;
        port cmdIn : StatusIF;
        port ctrlIn : ThermalIF;
    }

    public part def CommActuator {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataOut : CommandIF;
        port dataIn : ConfigIF;
        port pwrIn : ThermalIF;
    }

    // System Definition
    public part def PowerDistributionSystemSystem {
        part thermalprocessor : ThermalProcessor {
        }
        part powermodule : PowerModule {
            satisfy REQ_003;
        }
        part processingcontroller : ProcessingController {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part missioninterface : MissionInterface {
            satisfy REQ_003;
        }
        part commactuator : CommActuator {
            satisfy REQ_002;
        }

        // Connections
        connect missioninterface.cmdIn to processingcontroller.ctrlIn;
        connect commactuator.pwrIn to missioninterface.cmdIn;
        connect thermalprocessor.dataOut to commactuator.pwrIn;
        connect processingcontroller.ctrlIn to commactuator.dataOut;
    }

    // System Instance
    public part powerdistributionsystemsystem : PowerDistributionSystemSystem;

}