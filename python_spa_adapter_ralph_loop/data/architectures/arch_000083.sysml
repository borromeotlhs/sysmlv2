package arch_000083 {

    // Satellite Bus Reference Architecture 83
    // Domain: satellite bus

    // Requirements
    public requirement REQ_001 {
        doc "The satellite bus system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The satellite bus system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def DistributionInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut;
        port sensorOut;
    }

    public part def DataComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut;
        port dataIn;
    }

    // System Definition
    public part def SatelliteBusSystem {
        part distributioninterface : DistributionInterface {
            satisfy REQ_002;
        }
        part datacomputer : DataComputer {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect datacomputer.dataIn to distributioninterface.pwrOut;
        connect distributioninterface.sensorOut to datacomputer.dataIn;
        connect datacomputer.cmdOut to distributioninterface.pwrOut;
    }

    // System Instance
    part satellitebussystem : SatelliteBusSystem;

}