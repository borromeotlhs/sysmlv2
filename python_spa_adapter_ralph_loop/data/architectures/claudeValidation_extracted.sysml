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
    part def ElectricVehicleSystem {
    }

    part def ChargingSystem {
        port acIn : PowerPort;
        port controlIn : ControlPort;
        port dcOut : PowerPort;
        port sense : SensorPort;
    }

    part def DriveShaft {
        port driveIn : MechanicalPort;
        port driveOut : MechanicalPort;
    }

    part def ElectricMotor {
        port powerIn : PowerPort;
        port controlIn : ControlPort;
        port driveOut : MechanicalPort;
    }

    part def BatteryPack {
        port thermalin : ThermalPort;
        port dataOut : DataPort;
        port powerOut : PowerPort;
        port sense : SensorPort;
    }

    part def BrakeController {
        port canOut : DataPort;
    }

    part def Differential {
        port driveIn : MechanicalPort;
        port leftDriveOut : MechanicalPort;
        port rightDriveOut : MechanicalPort;
    }

    part def Suspension {
        port wheelHub : MechanicalPort;
    }

    part def Wheel {
        port wheelHub : MechanicalPort;
    }

    part def Transmission {
        port inputShaft : MechanicalPort;
        port torqueOut : MechanicalPort;
    }

    part def VehicleControlUnit {
        port canBusA : DataPort;
        port canBusB : DataPort;
        port sensorIn : SensorPort;
        port commandOut : ControlPort;
    }

    part def ThermalManagementSystem {
        port coolantout : ThermalPort;
        port dataout : DataPort;
        port sense : SensorPort;
    }

    part def Inverter {
        port dcIn : PowerPort;
        port controlIn : ControlPort;
        port acOut : PowerPort;
        port sense : SensorPort;
    }

    part def RearHalfShaft {
        port innerCVJoint : MechanicalPort;
        port outerCVJoint : MechanicalPort;
    }

    part def DrivetrainSystem {
        port canOut : DataPort;
        port powerIn : PowerPort;
        port commandOut : ControlPort;
        port rightOuterCVJoint : MechanicalPort;
        port leftOuterCVJoint : MechanicalPort;
    }

    part def ElectricalPowerSubsystem {
        port dataOut : DataPort;
        port acOut : PowerPort;
        port dataout : DataPort;
        port chrgsyscmdOut : Port;
        port invertercommandOut : ControlPort;
    }

    // System definition
    part def AutomotiveSystem {
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