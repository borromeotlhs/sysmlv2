package AutomotiveDomain {

    // Port type definitions
    port def ControlPort;
    port def DataPort;
    port def MechanicalPort;
    port def Port;
    port def PowerPort;
    port def SensorPort;
    port def ThermalPort;

    // Part definitions
    public part def ElectricVehicleSystem {
    }

    public part def ChargingSystem {
        port acIn : PowerPort;
        port controlIn : ControlPort;
        port dcOut : PowerPort;
        port sense : SensorPort;
    }

    public part def DriveShaft {
        port driveIn : MechanicalPort;
        port driveOut : MechanicalPort;
    }

    public part def ElectricMotor {
        port powerIn : PowerPort;
        port controlIn : ControlPort;
        port driveOut : MechanicalPort;
    }

    public part def BatteryPack {
        port thermalin : ThermalPort;
        port dataOut : DataPort;
        port powerOut : PowerPort;
        port sense : SensorPort;
    }

    public part def BrakeController {
        port canOut : DataPort;
    }

    public part def Differential {
        port driveIn : MechanicalPort;
        port leftDriveOut : MechanicalPort;
        port rightDriveOut : MechanicalPort;
    }

    public part def Suspension {
        port wheelHub : MechanicalPort;
    }

    public part def Wheel {
        port wheelHub : MechanicalPort;
    }

    public part def Transmission {
        port inputShaft : MechanicalPort;
        port torqueOut : MechanicalPort;
    }

    public part def VehicleControlUnit {
        port canBusA : DataPort;
        port canBusB : DataPort;
        port sensorIn : SensorPort;
        port commandOut : ControlPort;
    }

    public part def ThermalManagementSystem {
        port coolantout : ThermalPort;
        port dataout : DataPort;
        port sense : SensorPort;
    }

    public part def Inverter {
        port dcIn : PowerPort;
        port controlIn : ControlPort;
        port acOut : PowerPort;
        port sense : SensorPort;
    }

    public part def RearHalfShaft {
        port innerCVJoint : MechanicalPort;
        port outerCVJoint : MechanicalPort;
    }

    public part def DrivetrainSystem {
        port canOut : DataPort;
        port powerIn : PowerPort;
        port commandOut : ControlPort;
        port rightOuterCVJoint : MechanicalPort;
        port leftOuterCVJoint : MechanicalPort;
    }

    public part def ElectricalPowerSubsystem {
        port dataOut : DataPort;
        port acOut : PowerPort;
        port dataout : DataPort;
        port chrgsyscmdOut : Port;
        port invertercommandOut : ControlPort;
    }

    // System definition
    public part def AutomotiveSystem {
        part suspensionFL : Suspension;
        part suspensionFR : Suspension;
        part suspensionRL : Suspension;
        part suspensionRR : Suspension;
        part wheelFL : Wheel;
        part wheelFR : Wheel;
        part wheelRL : Wheel;
        part wheelRR : Wheel;
        part drivetrainSystem : DrivetrainSystem;
        part vehicleControlUnit : VehicleControlUnit;
        part electricalPowerSubsystem : ElectricalPowerSubsystem;
    }

    // System instance
    part automotiveSystem : AutomotiveSystem;
}