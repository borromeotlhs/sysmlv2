package arch_000051 {

    // Power Distribution System Reference Architecture 51
    // Domain: power distribution system

    // Requirements
    public requirement REQ_001 {
        doc "The power distribution system system shall exchange data through typed interfaces."
    }

    public requirement REQ_002 {
        doc "The power distribution system system shall trace subsystem design to requirements."
    }

    // Component Definitions
    public part def DataUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port telemetryOut;
    }

    public part def MonitorController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port dataIn;
        port ctrlIn;
        port telemetryOut;
    }

    public part def MonitorInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdOut;
        port cmdIn;
        port dataOut;
    }

    public part def DistributionComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port pwrIn;
        port cmdOut;
    }

    public part def FlightSubsystem {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port dataIn;
        port cmdIn;
    }

    public part def CommSubsystem {
        attribute frequency : Real [1];
        attribute bandwidth : Real [1];
        port dataIn;
        port cmdOut;
        port dataIn;
    }

    public part def SensorPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port configIn;
    }

    // System Definition
    public part def PowerDistributionSystemSystem {
        part dataunit : DataUnit {
        }
        part monitorcontroller : MonitorController {
            satisfy REQ_002;
        }
        part monitorinterface : MonitorInterface {
            satisfy REQ_002;
        }
        part distributioncomputer : DistributionComputer {
            satisfy REQ_001;
        }
        part flightsubsystem : FlightSubsystem {
        }
        part commsubsystem : CommSubsystem {
        }
        part sensorpayload : SensorPayload {
            satisfy REQ_001;
        }

        // Connections
        connect commsubsystem.dataIn to monitorinterface.cmdOut;
        connect flightsubsystem.cmdIn to monitorcontroller.dataIn;
        connect commsubsystem.cmdOut to distributioncomputer.pwrIn;
        connect flightsubsystem.dataIn to commsubsystem.dataIn;
    }

    // System Instance
    part powerdistributionsystemsystem : PowerDistributionSystemSystem;

}