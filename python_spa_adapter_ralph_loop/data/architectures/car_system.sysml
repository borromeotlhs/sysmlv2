package car_system {

    // Electric Vehicle System Architecture
    // Domain: automotive

    // Requirements
    public requirement REQ_001 {
        doc "The vehicle shall provide propulsion with at least 300 kW peak power."
    }

    public requirement REQ_002 {
        doc "The vehicle shall safely manage high-voltage electrical distribution."
    }

    public requirement REQ_003 {
        doc "The vehicle shall monitor and control battery thermal conditions."
    }

    public requirement REQ_004 {
        doc "The vehicle shall provide regenerative braking capability."
    }

    public requirement REQ_005 {
        doc "The vehicle shall maintain real-time communication between all control units."
    }

    // Port Interface Definitions
    port def PowerPort;
    port def ControlPort;
    port def DataPort;
    port def ThermalPort;
    port def MechanicalPort;
    port def CANPort;

    // Component Definitions
    public part def BatteryPack {
        attribute capacity : Real [1];  // kWh
        attribute voltage : Real [1];   // Volts
        attribute mass : Real [1];      // kg
        port powerOut : PowerPort;
        port thermalIn : ThermalPort;
        port dataOut : DataPort;
    }

    public part def ElectricMotor {
        attribute peakPower : Real [1];      // kW
        attribute continuousPower : Real [1]; // kW
        attribute maxTorque : Real [1];       // Nm
        attribute mass : Real [1];            // kg
        port powerIn : PowerPort;
        port controlIn : ControlPort;
        port driveOut : MechanicalPort;
    }

    public part def Inverter {
        attribute efficiency : Real [1];     // percent
        attribute maxCurrent : Real [1];     // Amps
        attribute coolingCapacity : Real [1]; // kW
        port dcIn : PowerPort;
        port acOut : PowerPort;
        port controlIn : ControlPort;
    }

    public part def ThermalManagementSystem {
        attribute coolingCapacity : Real [1];  // kW
        attribute pumpPower : Real [1];        // W
        attribute fluidVolume : Real [1];      // liters
        port coolantIn : ThermalPort;
        port coolantOut : ThermalPort;
        port dataOut : DataPort;
    }

    public part def BrakeController {
        attribute maxBrakingForce : Real [1];  // kN
        attribute responseTime : Real [1];      // ms
        port sensorIn : DataPort;
        port actuatorOut : ControlPort;
        port regenIn : PowerPort;
        port canOut : CANPort;
    }

    public part def VehicleControlUnit {
        attribute processingPower : Real [1];  // MIPS
        attribute memorySize : Real [1];       // GB
        attribute canChannels : Real [1];      // count
        port canBusA : CANPort;
        port canBusB : CANPort;
        port sensorIn : DataPort;
        port commandOut : ControlPort;
    }

    public part def ChargingSystem {
        attribute maxChargeRate : Real [1];  // kW
        attribute acInputVoltage : Real [1]; // V
        attribute dcOutputVoltage : Real [1]; // V
        port acIn : PowerPort;
        port dcOut : PowerPort;
        port controlIn : ControlPort;
    }

    public part def Transmission {
        attribute gearRatio : Real [1];
        attribute maxTorque : Real [1];  // Nm
        attribute efficiency : Real [1];  // percent
        port inputShaft : MechanicalPort;
        port outputShaft : MechanicalPort;
    }

    public part def Differential {
        attribute torqueSplitRatio : Real [1];
        attribute maxTorque : Real [1];  // Nm
        attribute mass : Real [1];  // kg
        port driveIn : MechanicalPort;
        port leftOut : MechanicalPort;
        port rightOut : MechanicalPort;
    }

    public part def DriveShaft {
        attribute length : Real [1];  // meters
        attribute diameter : Real [1];  // mm
        attribute maxTorque : Real [1];  // Nm
        port torqueIn : MechanicalPort;
        port torqueOut : MechanicalPort;
    }

    public part def Wheel {
        attribute diameter : Real [1];  // inches
        attribute width : Real [1];  // mm
        attribute mass : Real [1];  // kg
        port axleMount : MechanicalPort;
    }

    public part def Suspension {
        attribute springRate : Real [1];  // N/mm
        attribute damperRate : Real [1];  // N·s/mm
        attribute travelDistance : Real [1];  // mm
        port wheelMount : MechanicalPort;
        port chassisMount : MechanicalPort;
    }

    // System Definition
    public part def ElectricVehicleSystem {
        part batterypack : BatteryPack {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_003;
        }

        part electricmotor : ElectricMotor {
            satisfy REQ_001;
            satisfy REQ_004;
        }

        part inverter : Inverter {
            satisfy REQ_001;
            satisfy REQ_002;
        }

        part thermalmanagementsystem : ThermalManagementSystem {
            satisfy REQ_003;
        }

        part brakecontroller : BrakeController {
            satisfy REQ_004;
        }

        part vehiclecontrolunit : VehicleControlUnit {
            satisfy REQ_005;
        }

        part chargingsystem : ChargingSystem {
            satisfy REQ_002;
        }

        part transmission : Transmission {
            satisfy REQ_001;
        }

        part differential : Differential {
            satisfy REQ_001;
        }

        part driveshaft : DriveShaft {
            satisfy REQ_001;
        }

        part wheelFrontLeft : Wheel;
        part wheelFrontRight : Wheel;
        part wheelRearLeft : Wheel;
        part wheelRearRight : Wheel;

        part suspensionFrontLeft : Suspension;
        part suspensionFrontRight : Suspension;
        part suspensionRearLeft : Suspension;
        part suspensionRearRight : Suspension;

        // Power connections
        connect batterypack.powerOut to inverter.dcIn;
        connect inverter.acOut to electricmotor.powerIn;
        connect electricmotor.driveOut to transmission.inputShaft;
        connect transmission.outputShaft to driveshaft.torqueIn;
        connect driveshaft.torqueOut to differential.driveIn;
        connect differential.leftOut to wheelRearLeft.axleMount;
        connect differential.rightOut to wheelRearRight.axleMount;

        // Suspension connections
        connect suspensionFrontLeft.wheelMount to wheelFrontLeft.axleMount;
        connect suspensionFrontRight.wheelMount to wheelFrontRight.axleMount;
        connect suspensionRearLeft.wheelMount to wheelRearLeft.axleMount;
        connect suspensionRearRight.wheelMount to wheelRearRight.axleMount;

        // Thermal connections
        connect thermalmanagementsystem.coolantOut to batterypack.thermalIn;

        // Control/data connections
        connect vehiclecontrolunit.commandOut to electricmotor.controlIn;
        connect vehiclecontrolunit.commandOut to inverter.controlIn;
        connect batterypack.dataOut to vehiclecontrolunit.sensorIn;
        connect thermalmanagementsystem.dataOut to vehiclecontrolunit.canBusA;
        connect brakecontroller.canOut to vehiclecontrolunit.canBusB;
        connect vehiclecontrolunit.commandOut to chargingsystem.controlIn;
        connect chargingsystem.dcOut to batterypack.powerOut;
    }

    // System Instance
    part electricvehiclesystem : ElectricVehicleSystem;

}
