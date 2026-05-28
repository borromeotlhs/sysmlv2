package arch_000102 {

    import ScalarValues::*;

    // Thruster Assembly Reference Architecture 102
    // Domain: thruster assembly

    // Requirements
    public requirement REQ_001 {
        doc "The thruster assembly system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The thruster assembly system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def MissionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : ThermalIF;
        port pwrIn : StatusIF;
    }

    public part def DistributionSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : ThermalIF;
    }

    public part def FlightSensor {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port ctrlIn : ThermalIF;
        port cmdIn : ThermalIF;
    }

    // System Definition
    public part def ThrusterAssemblySystem {
        part missionunit : MissionUnit {
            satisfy REQ_001;
        }
        part distributionsubsystem : DistributionSubsystem {
        }
        part flightsensor : FlightSensor {
            satisfy REQ_002;
        }

        // Connections
        connect missionunit.dataIn to flightsensor.cmdIn;
        connect missionunit.pwrIn to flightsensor.ctrlIn;
        connect missionunit.dataIn to distributionsubsystem.cmdOut;
        connect distributionsubsystem.cmdOut to missionunit.pwrIn;
    }

    // System Instance
    public part thrusterassemblysystem : ThrusterAssemblySystem;

}