package arch_000042 {

    import ScalarValues::*;

    // Thruster Assembly Reference Architecture 42
    // Domain: thruster assembly

    // Requirements
    public requirement REQ_001 {
        doc "The thruster assembly system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The thruster assembly system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def ThermalIF;

    // Component Definitions
    public part def PowerComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port telemetryOut : SignalIF;
        port ctrlIn : ThermalIF;
    }

    public part def PowerBus {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port sensorOut : SignalIF;
    }

    public part def FlightAssembly {
        attribute mass : Real [1];
        attribute power : Real [1];
        port pwrIn : PowerIF;
        port cmdOut : DiagnosticIF;
        port configIn : ThermalIF;
    }

    // System Definition
    public part def ThrusterAssemblySystem {
        part powercomputer : PowerComputer {
            satisfy REQ_001;
        }
        part powerbus : PowerBus {
            satisfy REQ_002;
        }
        part flightassembly : FlightAssembly {
        }

        // Connections
        connect powercomputer.telemetryOut to flightassembly.configIn;
        connect powercomputer.ctrlIn to flightassembly.configIn;
        connect flightassembly.pwrIn to powerbus.sensorOut;
    }

    // System Instance
    public part thrusterassemblysystem : ThrusterAssemblySystem;

}