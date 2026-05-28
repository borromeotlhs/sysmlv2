package arch_000018 {

    import ScalarValues::*;

    // Solar Array Reference Architecture 18
    // Domain: solar array

    // Requirements
    public requirement REQ_001 {
        doc "The solar array system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The solar array system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The solar array system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The solar array system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def CommandIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def PowerInterface {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port cmdOut : PowerIF;
        port cmdIn : StatusIF;
        port ctrlIn : DiagnosticIF;
    }

    public part def FlightProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn : CommandIF;
        port dataOut : SignalIF;
    }

    public part def DataProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn : TelemetryIF;
        port cmdOut : ThermalIF;
        port pwrIn : DiagnosticIF;
    }

    // System Definition
    public part def SolarArraySystem {
        part powerinterface : PowerInterface {
            satisfy REQ_003;
        }
        part flightprocessor : FlightProcessor {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_004;
        }
        part dataprocessor : DataProcessor {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
            satisfy REQ_004;
        }

        // Connections
        connect dataprocessor.cmdOut to powerinterface.cmdIn;
        connect flightprocessor.pwrIn to powerinterface.ctrlIn;
        connect dataprocessor.pwrIn to powerinterface.cmdIn;
    }

    // System Instance
    public part solararraysystem : SolarArraySystem;

}