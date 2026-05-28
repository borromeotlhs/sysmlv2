package arch_000083 {

    import ScalarValues::*;

    // Satellite Bus Reference Architecture 83
    // Domain: satellite bus

    // Requirements
    public requirement REQ_001 {
        doc "The satellite bus system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The satellite bus system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def SignalIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def DistributionInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrOut : SignalIF;
        port sensorOut : ConfigIF;
    }

    public part def DataComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut : CommandIF;
        port dataIn : TelemetryIF;
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
    public part satellitebussystem : SatelliteBusSystem;

}