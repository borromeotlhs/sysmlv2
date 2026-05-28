package arch_000124 {

    // Satellite Bus Reference Architecture 124
    // Domain: satellite bus

    // Requirements
    requirement REQ_001 {
        doc "The satellite bus system shall exchange data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The satellite bus system shall trace subsystem design to requirements."
    }

    // Component Definitions
    part def DistributionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port sensorOut;
        port dataIn;
    }

    part def DataComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn;
        port sensorOut;
        port statusOut;
    }

    part def DataActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
        port statusOut;
        port ctrlIn;
    }

    part def FlightController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut;
        port dataOut;
    }

    // System Definition
    part def SatelliteBusSystem {
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