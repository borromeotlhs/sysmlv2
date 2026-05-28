package arch_000043 {

    // Solar Array Reference Architecture 43
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

    // Component Definitions
    public part def NavInterface {
        attribute mass : Real [1];
        attribute power : Real [1];
        port configIn;
        port sensorOut;
        port dataIn;
    }

    public part def DataUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port cmdIn;
    }

    public part def ThermalUnit {
        attribute mass : Real [1];
        attribute power : Real [1];
        port dataIn;
        port cmdIn;
    }

    public part def MonitorComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port configIn;
        port cmdOut;
    }

    public part def DistributionController {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port ctrlIn;
        port sensorOut;
    }

    // System Definition
    public part def SolarArraySystem {
        part navinterface : NavInterface {
            satisfy REQ_001;
        }
        part dataunit : DataUnit {
            satisfy REQ_002;
        }
        part thermalunit : ThermalUnit {
            satisfy REQ_002;
        }
        part monitorcomputer : MonitorComputer {
        }
        part distributioncontroller : DistributionController {
            satisfy REQ_003;
        }

        // Connections
        connect distributioncontroller.ctrlIn to monitorcomputer.cmdOut;
        connect dataunit.cmdIn to navinterface.sensorOut;
        connect navinterface.dataIn to monitorcomputer.cmdOut;
    }

    // System Instance
    part solararraysystem : SolarArraySystem;

}