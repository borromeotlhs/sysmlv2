package test_view_filter {

    import ScalarValues::*;

    // Test architecture for view filtering
    // Domain: test

    // Requirements
    public requirement REQ_001 {
        doc "The system shall provide filtered views."
    }

    // Port Definitions
    public port def CommandPort;
    public port def DataPort;
    public port def ProcessPort;
    public port def PowerPort;

    // Public components (visible in filtered views)
    public part def ControlUnit {
        attribute processingPower : Real [1];
        port cmdIn : CommandPort;
        port cmdOut : CommandPort;
    }

    public part def SensorModule {
        attribute resolution : Real [1];
        port dataOut : DataPort;
    }

    // Private/internal component (hidden in filtered views)
    public part def InternalProcessor {
        attribute cores : Real [1];
        port procIn : ProcessPort;
        port procOut : ProcessPort;
    }

    public part def PowerSupply {
        attribute voltage : Real [1];
        port pwrOut : PowerPort;
    }

    // System Definition
    public part def TestSystem {
        part control : ControlUnit {
            satisfy REQ_001;
        }
        part sensor : SensorModule;
        part processor : InternalProcessor;
        part power : PowerSupply;

        // Connections
        connect control.cmdOut to sensor.dataOut;
        connect control.cmdIn to processor.procOut;
        connect power.pwrOut to processor.procIn;
    }

    // System Instance
    public part testSystem : TestSystem;
}
