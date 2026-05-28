package arch_000032 {

    import ScalarValues::*;

    // Ground Station Reference Architecture 32
    // Domain: ground station

    // Requirements
    public requirement REQ_001 {
        doc "The ground station system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The ground station system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def ProcessingController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port sensorOut : DataIF;
        port telemetryOut : StatusIF;
        port sensorOut : ControlIF;
    }

    public part def PowerSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut : SignalIF;
    }

    public part def CommInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataOut : ControlIF;
    }

    public part def DistributionAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : ThermalIF;
        port dataIn : PowerIF;
    }

    public part def CommandInterface {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrIn : DataIF;
    }

    public part def ProcessingBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut : ConfigIF;
        port cmdIn : ControlIF;
        port configIn : PowerIF;
    }

    // System Definition
    public part def GroundStationSystem {
        part processingcontroller : ProcessingController {
        }
        part powersensor : PowerSensor {
            satisfy REQ_001;
        }
        part comminterface : CommInterface {
        }
        part distributionassembly : DistributionAssembly {
            satisfy REQ_001;
        }
        part commandinterface : CommandInterface {
            satisfy REQ_002;
        }
        part processingbus : ProcessingBus {
            satisfy REQ_002;
        }

        // Connections
        connect processingcontroller.sensorOut to processingbus.cmdIn;
        connect commandinterface.pwrIn to processingcontroller.sensorOut;
        connect distributionassembly.dataOut to processingbus.configIn;
        connect commandinterface.pwrIn to processingbus.cmdIn;
        connect commandinterface.pwrIn to powersensor.pwrOut;
    }

    // System Instance
    public part groundstationsystem : GroundStationSystem;

}