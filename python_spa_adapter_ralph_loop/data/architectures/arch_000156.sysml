package arch_000156 {

    // Communication Relay Reference Architecture 156
    // Domain: communication relay

    // Requirements
    public requirement REQ_001 {
        doc "The communication relay system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The communication relay system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def NavPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port telemetryOut;
        port pwrIn;
        port dataIn;
    }

    public part def ProcessingSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
    }

    public part def MonitorBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
    }

    public part def ControlBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
    }

    public part def NavUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataOut;
        port telemetryOut;
        port dataOut;
    }

    public part def ControlActuator {
        attribute mass : Real [1];
        attribute power : Real [1];
        port ctrlIn;
        port ctrlIn;
    }

    public part def ThermalBus {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
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
    part communicationrelaysystem : CommunicationRelaySystem;

}