package UAVMission {

    import ScalarValues::*;

    // UAV System Architecture
    // Domain: unmanned aerial vehicle
    // Designed for conversion to SAJAI 3D visualization format

    // Requirements
    public requirement REQ_POWER_001 {
        doc /* The UAV system shall provide sufficient power to all subsystems. */
    }

    public requirement REQ_NAV_001 {
        doc /* The UAV system shall maintain accurate position tracking via GPS. */
    }

    public requirement REQ_COMM_001 {
        doc /* The UAV system shall maintain reliable telemetry communication. */
    }

    // Port Definitions
    public port def PowerIF {
        attribute voltage : Real [1];
        attribute current : Real [1];
    }

    public port def DataIF {
        attribute protocol : String [1];
        attribute baudRate : Integer [1];
    }

    public port def GPSIF {
        attribute protocol : String [1];
        attribute updateRate : Real [1];
    }

    public port def TelemetryIF {
        attribute frequency : Real [1];
        attribute protocol : String [1];
    }

    public port def SPIIF {
        attribute protocol : String [1];
        attribute maxSpeed : Real [1];
    }

    public port def I2CIF {
        attribute protocol : String [1];
        attribute address : String [1];
    }

    // Internal Component Definitions for Flight Controller
    public part def MicrocontrollerType {
        attribute processorSpeed : Real [1];
        attribute clockSpeed : Real [1];
        attribute flash : Real [1];
        attribute ram : Real [1];
        port spi1 : SPIIF;
        port i2c1 : I2CIF;
        port i2c2 : I2CIF;
    }

    public part def IMUSensorType {
        attribute accelerometer : String [1];
        attribute gyroscope : String [1];
        attribute updateRate : Real [1];
        attribute range : String [1];
        port spiInterface : SPIIF;
    }

    public part def BarometerType {
        attribute sensor : String [1];
        attribute resolution : Real [1];
        attribute updateRate : Real [1];
        port i2cInterface : I2CIF;
    }

    public part def CompassType {
        attribute sensor : String [1];
        attribute resolution : String [1];
        attribute updateRate : Real [1];
        port i2cInterface : I2CIF;
    }

    // Flight Controller with Internal Structure
    public part def FlightControllerType {
        attribute processorSpeed : Real [1];
        attribute memory : String [1];
        attribute firmware : String [1];
        attribute weight : Real [1];

        // Internal components
        part mcu : MicrocontrollerType;
        part imu : IMUSensorType;
        part barometer : BarometerType;
        part compass : CompassType;

        // External ports
        port powerIn : PowerIF;
        port gpsDataIn : DataIF;
        port telemetryOut : DataIF;

        // Internal SPI connections
        connect mcu.spi1 to imu.spiInterface;

        // Internal I2C connections
        connect mcu.i2c1 to barometer.i2cInterface;
        connect mcu.i2c2 to compass.i2cInterface;
    }

    // GPS Module Definition
    public part def GPSModuleType {
        attribute accuracy : Real [1];
        attribute updateRate : Real [1];
        attribute protocol : String [1];
        attribute weight : Real [1];
        port powerIn : PowerIF;
        port dataOut : GPSIF;
    }

    // Battery Definition
    public part def LiPoBatteryType {
        attribute capacity : Real [1];
        attribute voltage : Real [1];
        attribute dischargeCurrent : String [1];
        attribute weight : Real [1];
        port mainPower : PowerIF;
        port auxPower : PowerIF;
    }

    // Telemetry Radio Definition
    public part def TelemetryRadioType {
        attribute frequency : Real [1];
        attribute range : Real [1];
        attribute protocol : String [1];
        attribute weight : Real [1];
        port powerIn : PowerIF;
        port dataIn : TelemetryIF;
    }

    // Main UAV System Definition
    public part def UAV {

        // System Parts
        part flightController : FlightControllerType {
            satisfy REQ_POWER_001;
        }

        part gpsModule : GPSModuleType {
            satisfy REQ_NAV_001;
        }

        part powerSupply : LiPoBatteryType {
            satisfy REQ_POWER_001;
        }

        part telemetryRadio : TelemetryRadioType {
            satisfy REQ_COMM_001;
        }

        // Power Connections
        connect powerSupply.mainPower to flightController.powerIn;
        connect powerSupply.auxPower to gpsModule.powerIn;

        // Data Connections
        connect gpsModule.dataOut to flightController.gpsDataIn;
        connect flightController.telemetryOut to telemetryRadio.dataIn;
    }

    // System Instance
    public part system : UAV;

}
