package arch_000004 {

    // Satellite Bus Reference Architecture 4
    // Domain: satellite bus

    // Requirements
    public requirement REQ_001 {
        doc "The satellite bus system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The satellite bus system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def DistributionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port sensorOut;
        port dataIn;
    }

    public part def DataComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn;
        port sensorOut;
        port statusOut;
    }

    public part def DataActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
        port statusOut;
        port ctrlIn;
    }

    public part def FlightController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut;
        port dataOut;
    }

    // System Definition
    public part def SatelliteBusSystem {
        part distributionunit : DistributionUnit {
            satisfy REQ_001;
        }
        part datacomputer : DataComputer {
        }
        part dataactuator : DataActuator {
        }
        part flightcontroller : FlightController {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect distributionunit.ctrlIn to flightcontroller.cmdOut;
        connect datacomputer.dataIn to flightcontroller.cmdOut;
        connect flightcontroller.dataOut to distributionunit.ctrlIn;
        connect datacomputer.statusOut to distributionunit.sensorOut;
    }

    // System Instance
    part satellitebussystem : SatelliteBusSystem;

}