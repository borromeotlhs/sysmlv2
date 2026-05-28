package arch_000005 {

    import ScalarValues::*;

    // Power Distribution System Reference Architecture 5
    // Domain: power distribution system

    // Requirements
    public requirement REQ_001 {
        doc "The power distribution system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The power distribution system system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def DataIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def DistributionSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn : DataIF;
        port cmdIn : StatusIF;
    }

    public part def DataController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut : DataIF;
        port dataOut : ThermalIF;
        port dataOut : ConfigIF;
    }

    public part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : StatusIF;
        port dataIn : SignalIF;
    }

    public part def CommAssembly {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataOut : DataIF;
        port ctrlIn : ConfigIF;
    }

    public part def CommSubsystem {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port cmdIn : ConfigIF;
    }

    // System Definition
    public part def PowerDistributionSystemSystem {
        part distributionsubsystem : DistributionSubsystem {
            satisfy REQ_001;
            satisfy REQ_002;
        }
        part datacontroller : DataController {
            satisfy REQ_001;
        }
        part flightinterface : FlightInterface {
        }
        part commassembly : CommAssembly {
            satisfy REQ_002;
        }
        part commsubsystem : CommSubsystem {
        }

        // Connections
        connect distributionsubsystem.cmdIn to datacontroller.dataOut;
        connect flightinterface.dataIn to commassembly.dataOut;
    }

    // System Instance
    public part powerdistributionsystemsystem : PowerDistributionSystemSystem;

}