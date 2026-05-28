// Corrected Electric Vehicle System Architecture
// Generated from complete extraction JSON
// This model captures the proper hierarchy: Domain → Vehicle → Subsystems → Components

package AutomotiveDomain {
    // Note: Original model had <<domain>> stereotype on this package

    // Port Definitions (package level)
    port def PowerPort;
    port def ControlPort;
    port def DataPort;
    port def MechanicalPort;
    port def ThermalPort;
    port def CANPort;

    // Component Definitions
    part def ChargingSystem {
        port acIn : PowerPort;
        port controlIn : ControlPort;
        port dcOut : PowerPort;
        port sense : DataPort;
    }

    part def BatteryPack {
        port thermalIn : ThermalPort;
        port dataOut : DataPort;
        port powerOut : PowerPort;
        port sense : DataPort;
    }

    part def Inverter {
        port dcIn : PowerPort;
        port controlIn : ControlPort;
        port acOut : PowerPort;
        port sense : DataPort;
    }

    part def ThermalManagementSystem {
        port coolantOut : ThermalPort;
        port dataOut : DataPort;
        port sense : DataPort;
    }

    part def ElectricMotor {
        port powerIn : PowerPort;
        port controlIn : ControlPort;
        port driveOut : MechanicalPort;
    }

    part def Transmission {
        port inputShaft : MechanicalPort;
        port torqueOut : MechanicalPort;
    }

    part def DriveShaft {
        port driveIn : MechanicalPort;
        port driveOut : MechanicalPort;
    }

    part def Differential {
        port driveIn : MechanicalPort;
        port leftDriveOut : MechanicalPort;
        port rightDriveOut : MechanicalPort;
    }

    part def RearHalfShaft {
        port innerCVJoint : MechanicalPort;
        port outerCVJoint : MechanicalPort;
    }

    part def BrakeController {
        port canOut : CANPort;
    }

    part def VehicleControlUnit {
        port canBusA : CANPort;
        port canBusB : CANPort;
        port sensorIn : DataPort;
        port commandOut : ControlPort;
    }

    part def Wheel {
        port wheelHub : MechanicalPort;
    }

    part def Suspension {
        port wheelHub : MechanicalPort;
    }

    // Subsystem Definitions
    part def DrivetrainSystem {
        part brakeController : BrakeController[1];
        part electricMotor : ElectricMotor[1];
        part transmission : Transmission[1];
        part differential : Differential[1];
        part driveShaft : DriveShaft[1];
        part left : RearHalfShaft[1];
        part right : RearHalfShaft[1];

        port canOut : CANPort;
        port powerIn : PowerPort;
        port commandOut : ControlPort;
        port leftOuterCVJoint : MechanicalPort;
        port rightOuterCVJoint : MechanicalPort;

        // Internal connections
        connect electricMotor.driveOut to transmission.inputShaft;
        connect transmission.torqueOut to driveShaft.driveIn;
        connect driveShaft.driveOut to differential.driveIn;
        connect differential.leftDriveOut to left.innerCVJoint;
        connect differential.rightDriveOut to right.innerCVJoint;
        connect left.outerCVJoint to leftOuterCVJoint;
        connect right.outerCVJoint to rightOuterCVJoint;
        connect brakeController.canOut to canOut;
        connect electricMotor.powerIn to powerIn;
        connect electricMotor.controlIn to commandOut;
    }

    part def ElectricalPowerSubsystem {
        part chargingSystem : ChargingSystem[1];
        part batteryPack : BatteryPack[1];
        part inverter : Inverter[1];
        part thermalManagementSystem : ThermalManagementSystem[1];

        port dataOut : DataPort;
        port acOut : PowerPort;
        port dataOut2 : DataPort;
        port chargingSysCmdOut : ControlPort;
        port inverterCommandOut : ControlPort;

        // Internal connections
        connect thermalManagementSystem.coolantOut to batteryPack.thermalIn;
        connect batteryPack.powerOut to inverter.dcIn;
        connect chargingSystem.dcOut to batteryPack.powerOut;
        connect batteryPack.dataOut to dataOut;
        connect inverter.acOut to acOut;
        connect thermalManagementSystem.dataOut to dataOut2;
        connect chargingSysCmdOut to chargingSystem.controlIn;
        connect inverterCommandOut to inverter.controlIn;
        connect thermalManagementSystem.sense to batteryPack.sense;
        connect thermalManagementSystem.sense to inverter.sense;
        connect thermalManagementSystem.sense to chargingSystem.sense;
    }

    // Electric Vehicle System (properly nested within domain)
    part def ElectricVehicleSystem {
        // Suspension and wheels
        part suspensionFL : Suspension[1..1];
        part suspensionFR : Suspension[1..1];
        part suspensionRL : Suspension[1..1];
        part suspensionRR : Suspension[1..1];
        part wheelFL : Wheel[1..1];
        part wheelFR : Wheel[1..1];
        part wheelRL : Wheel[1..1];
        part wheelRR : Wheel[1..1];

        // Major subsystems
        part drivetrainSystem : DrivetrainSystem[1];
        part electricalPowerSubsystem : ElectricalPowerSubsystem[1];
        part vehicleControlUnit : VehicleControlUnit[1];

        // Top-level connections
        connect vehicleControlUnit.commandOut to electricalPowerSubsystem.inverterCommandOut;
        connect electricalPowerSubsystem.dataOut to vehicleControlUnit.sensorIn;
        connect drivetrainSystem.canOut to vehicleControlUnit.canBusB;
        connect electricalPowerSubsystem.acOut to drivetrainSystem.powerIn;
        connect electricalPowerSubsystem.dataOut2 to vehicleControlUnit.canBusA;
        connect vehicleControlUnit.commandOut to electricalPowerSubsystem.chargingSysCmdOut;
        connect vehicleControlUnit.commandOut to drivetrainSystem.commandOut;
        connect drivetrainSystem.leftOuterCVJoint to wheelRL.wheelHub;
        connect drivetrainSystem.rightOuterCVJoint to wheelRR.wheelHub;
        connect wheelRR.wheelHub to suspensionRR.wheelHub;
        connect wheelRL.wheelHub to suspensionRL.wheelHub;
    }

    // Domain contains the vehicle system
    part electricVehicleSystem : ElectricVehicleSystem[1];
}
