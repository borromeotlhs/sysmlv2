package arch_000188 {

    import ScalarValues::*;

    // Reaction Wheel Reference Architecture 188
    // Domain: reaction wheel

    // Requirements
    public requirement REQ_001 {
        doc "The reaction wheel system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The reaction wheel system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def DiagnosticIF;
    public port def PowerIF;
    public port def SignalIF;
    public port def TelemetryIF;
    public port def ThermalIF;

    // Component Definitions
    public part def PowerBus {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port configIn : CommandIF;
        port pwrIn : TelemetryIF;
    }

    public part def DataBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn : DiagnosticIF;
        port dataIn : TelemetryIF;
        port ctrlIn : SignalIF;
    }

    public part def SensorSubsystem {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataOut : ThermalIF;
    }

    public part def FlightProcessor {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataOut : CommandIF;
        port pwrOut : DiagnosticIF;
        port cmdOut : PowerIF;
    }

    // System Definition
    public part def ReactionWheelSystem {
        part powerbus : PowerBus {
            satisfy REQ_001;
        }
        part databus : DataBus {
            satisfy REQ_001;
        }
        part sensorsubsystem : SensorSubsystem {
            satisfy REQ_002;
        }
        part flightprocessor : FlightProcessor {
            satisfy REQ_002;
        }

        // Connections
        connect flightprocessor.dataOut to databus.dataIn;
        connect powerbus.pwrIn to sensorsubsystem.dataOut;
        connect databus.dataIn to powerbus.configIn;
        connect flightprocessor.cmdOut to sensorsubsystem.dataOut;
        connect flightprocessor.pwrOut to databus.ctrlIn;
    }

    // System Instance
    public part reactionwheelsystem : ReactionWheelSystem;

}