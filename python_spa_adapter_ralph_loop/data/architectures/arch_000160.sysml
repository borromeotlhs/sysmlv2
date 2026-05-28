package arch_000160 {

    import ScalarValues::*;

    // Guidance Navigation Reference Architecture 160
    // Domain: guidance navigation

    // Requirements
    public requirement REQ_001 {
        doc "The guidance navigation system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The guidance navigation system shall trace subsystem design to requirements."
    }

    public requirement REQ_003 {
        doc "The guidance navigation system shall provide fault detection and recovery."
    }

    public requirement REQ_004 {
        doc "The guidance navigation system shall maintain operational status monitoring."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def DiagnosticIF;
    public port def SignalIF;
    public port def StatusIF;
    public port def TelemetryIF;

    // Component Definitions
    public part def MissionUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : ConfigIF;
        port configIn : DiagnosticIF;
        port telemetryOut : TelemetryIF;
    }

    public part def SensorActuator {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port pwrOut : StatusIF;
        port dataOut : SignalIF;
        port cmdOut : CommandIF;
    }

    public part def CommandBus {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port pwrOut : StatusIF;
        port dataIn : ConfigIF;
        port sensorOut : SignalIF;
    }

    public part def CommPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port cmdOut : ConfigIF;
    }

    // System Definition
    public part def GuidanceNavigationSystem {
        part missionunit : MissionUnit {
        }
        part sensoractuator : SensorActuator {
            satisfy REQ_002;
        }
        part commandbus : CommandBus {
            satisfy REQ_002;
            satisfy REQ_003;
            satisfy REQ_004;
        }
        part commpayload : CommPayload {
            satisfy REQ_001;
            satisfy REQ_004;
        }

        // Connections
        connect commandbus.sensorOut to sensoractuator.cmdOut;
        connect missionunit.dataOut to commandbus.sensorOut;
        connect sensoractuator.dataOut to commandbus.pwrOut;
        connect missionunit.configIn to commandbus.dataIn;
    }

    // System Instance
    public part guidancenavigationsystem : GuidanceNavigationSystem;

}