package arch_000005 {

    // Power Distribution System Reference Architecture 5
    // Domain: power distribution system

    // Requirements
    public requirement REQ_001 {
        doc "The power distribution system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The power distribution system system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def DistributionSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
        port cmdIn;
    }

    public part def DataController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrOut;
        port dataOut;
        port dataOut;
    }

    public part def FlightInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port dataIn;
    }

    public part def CommAssembly {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataOut;
        port ctrlIn;
    }

    public part def CommSubsystem {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port cmdIn;
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
    part powerdistributionsystemsystem : PowerDistributionSystemSystem;

}