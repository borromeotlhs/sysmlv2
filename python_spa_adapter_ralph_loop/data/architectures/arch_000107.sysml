package arch_000107 {

    // Ground Station Reference Architecture 107
    // Domain: ground station

    // Requirements
    public requirement REQ_001 {
        doc "The ground station system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The ground station system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The ground station system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The ground station system shall maintain operational status monitoring."
    }

    // Component Definitions
    public part def MissionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port sensorOut;
        port sensorOut;
    }

    public part def DataModule {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port cmdIn;
        port pwrOut;
    }

    public part def ThermalComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
    }

    public part def DistributionBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
        port pwrIn;
        port cmdOut;
    }

    // System Definition
    public part def GroundStationSystem {
        part missionunit : MissionUnit {
            satisfy REQ_004;
        }
        part datamodule : DataModule {
            satisfy REQ_002;
        }
        part thermalcomputer : ThermalComputer {
            satisfy REQ_001;
        }
        part distributionbus : DistributionBus {
            satisfy REQ_003;
            satisfy REQ_004;
        }

        // Connections
        connect datamodule.cmdIn to missionunit.sensorOut;
        connect distributionbus.pwrIn to datamodule.dataIn;
        connect missionunit.sensorOut to datamodule.pwrOut;
        connect distributionbus.dataOut to missionunit.sensorOut;
        connect distributionbus.cmdOut to missionunit.sensorOut;
    }

    // System Instance
    part groundstationsystem : GroundStationSystem;

}