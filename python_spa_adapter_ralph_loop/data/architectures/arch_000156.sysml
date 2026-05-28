package arch_000156 {

    import ScalarValues::*;

    // Communication Relay Reference Architecture 156
    // Domain: communication relay

    // Requirements
    public requirement REQ_001 {
        doc "The communication relay system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The communication relay system shall trace subsystem design to requirements."
    }

    // Port Definitions
    public port def CommandIF;
    public port def ConfigIF;
    public port def DataIF;
    public port def PowerIF;
    public port def StatusIF;

    // Component Definitions
    public part def NavPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut : StatusIF;
        port pwrIn : DataIF;
        port dataIn : PowerIF;
    }

    public part def ProcessingSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : DataIF;
    }

    public part def MonitorBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : CommandIF;
    }

    public part def ControlBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : PowerIF;
    }

    public part def NavUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut : StatusIF;
        port telemetryOut : ConfigIF;
        port dataOut : DataIF;
    }

    public part def ControlActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn : PowerIF;
        port ctrlIn : StatusIF;
    }

    public part def ThermalBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut : PowerIF;
    }

    // System Definition
    public part def CommunicationRelaySystem {
        part navpayload : NavPayload {
            satisfy REQ_001;
        }
        part processingsubsystem : ProcessingSubsystem {
        }
        part monitorbus : MonitorBus {
        }
        part controlbus : ControlBus {
            satisfy REQ_002;
        }
        part navunit : NavUnit {
        }
        part controlactuator : ControlActuator {
        }
        part thermalbus : ThermalBus {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        // Connections
        connect navunit.telemetryOut to navpayload.telemetryOut;
        connect controlactuator.ctrlIn to processingsubsystem.dataOut;
        connect monitorbus.dataOut to controlactuator.ctrlIn;
    }

    // System Instance
    public part communicationrelaysystem : CommunicationRelaySystem;

}