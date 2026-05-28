package arch_000004 {

    import ScalarValues::*;

    // Satellite Bus Reference Architecture 4
    // Domain: satellite bus

    // Requirements
    public requirement REQ_001 {
        doc "The satellite bus system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The satellite bus system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def ControlIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def DistributionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : DataIF;
        port sensorOut : PowerIF;
        port dataIn : TelemetryIF;
    }

    public part def DataComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn : SignalIF;
        port sensorOut : DiagnosticIF;
        port statusOut : ThermalIF;
    }

    public part def DataActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : SignalIF;
        port statusOut : ControlIF;
        port ctrlIn : ConfigIF;
    }

    public part def FlightController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut : ThermalIF;
        port dataOut : DataIF;
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
    public part satellitebussystem : SatelliteBusSystem;

}