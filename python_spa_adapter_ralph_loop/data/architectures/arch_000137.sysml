package arch_000137 {

    import ScalarValues::*;

    // Life Support Reference Architecture 137
    // Domain: life support

    // Requirements
    public requirement REQ_001 {
        doc "The life support system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The life support system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The life support system shall provide fault detection and recovery."
    }

    // Port Definitions
    public port def ConfigIF;
    public port def DataIF;
    public port def DiagnosticIF;
    public port def StatusIF;
    public port def ThermalIF;

    // Component Definitions
    public part def NavAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : DiagnosticIF;
        port sensorOut : ThermalIF;
        port pwrIn : ThermalIF;
    }

    public part def FlightAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : ConfigIF;
    }

    public part def MissionActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut : DataIF;
        port sensorOut : StatusIF;
    }

    // System Definition
    public part def LifeSupportSystem {
        part navassembly : NavAssembly {
            satisfy REQ_001;
            satisfy REQ_003;
        }
        part flightassembly : FlightAssembly {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }
        part missionactuator : MissionActuator {
            satisfy REQ_002;
        }

        // Connections
        connect flightassembly.cmdOut to navassembly.pwrIn;
        connect navassembly.dataOut to missionactuator.sensorOut;
        connect flightassembly.cmdOut to navassembly.sensorOut;
    }

    // System Instance
    public part lifesupportsystem : LifeSupportSystem;

}