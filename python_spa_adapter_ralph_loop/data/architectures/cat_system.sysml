package FelineBiologicalSystem {

    import ScalarValues::*;

    // Felidae Reference Architecture
    // Domain: biological system

    // Requirements - Each requirement is atomic (single responsibility)
    public requirement REQ_001 {
        doc "The cat shall maintain balance during movement."
    }

    public requirement REQ_002 {
        doc "The cat shall demonstrate agility in navigation."
    }

    public requirement REQ_003 {
        doc "The cat shall detect prey through sensory processing."
    }

    public requirement REQ_004 {
        doc "The cat shall climb vertical surfaces."
    }

    public requirement REQ_005 {
        doc "The cat shall process visual sensory information."
    }

    public requirement REQ_006 {
        doc "The cat shall process auditory sensory information."
    }

    public requirement REQ_007 {
        doc "The cat shall process tactile sensory information."
    }

    public requirement REQ_008 {
        doc "The cat shall regulate body temperature."
    }

    public requirement REQ_009 {
        doc "The cat shall perform grooming behavior."
    }

    public requirement REQ_010 {
        doc "The cat shall vocalize for communication."
    }

    public requirement REQ_011 {
        doc "The cat shall mark territory."
    }

    public requirement REQ_012 {
        doc "The cat shall retract claws when not in use."
    }

    public requirement REQ_013 {
        doc "The cat shall land on feet when falling."
    }

    // Port Definitions
    public port def SensoryInputPort;
    public port def MotorOutputPort;
    public port def NeuralSignalPort;
    public port def MetabolicPort;
    public port def VocalPort;
    public port def TactilePort;

    // Component Definitions
    public part def Brain {
        attribute mass : Real [1];
        attribute neuronCount : Real [1];
        port sensoryIn : SensoryInputPort;
        port motorOut : MotorOutputPort;
        port cognitionSignal : NeuralSignalPort;
    }

    public part def Eyes {
        attribute fieldOfView : Real [1];
        attribute nightVisionCapable : Real [1];
        port visualData : SensoryInputPort;
    }

    public part def Ears {
        attribute rotationDegrees : Real [1];
        attribute frequencyRangeHz : Real [1];
        port audioData : SensoryInputPort;
    }

    public part def Whiskers {
        attribute count : Real [1];
        attribute sensitivity : Real [1];
        port tactileData : TactilePort;
    }

    public part def Nose {
        attribute olfactoryReceptors : Real [1];
        port smellData : SensoryInputPort;
    }

    public part def Legs {
        attribute length : Real [1];
        attribute retractableClaws : Real [1];
        port motorControl : MotorOutputPort;
    }

    public part def Tail {
        attribute length : Real [1];
        attribute vertebraeCount : Real [1];
        port balanceControl : MotorOutputPort;
    }

    public part def VocalCords {
        attribute purringCapable : Real [1];
        attribute meowFrequencyHz : Real [1];
        port vocalizationOut : VocalPort;
    }

    public part def DigestiveSystem {
        attribute carnivorousAdapted : Real [1];
        attribute stomachCapacity : Real [1];
        port nutrientIntake : MetabolicPort;
        port wasteOutput : MetabolicPort;
    }

    public part def Fur {
        attribute layerCount : Real [1];
        attribute insulationFactor : Real [1];
        port thermalRegulation : MetabolicPort;
    }

    public part def ScentGlands {
        attribute pheromoneProduction : Real [1];
        port scentMarking : MetabolicPort;
    }

    public part def Tongue {
        attribute papillaeCount : Real [1];
        attribute groomingEfficiency : Real [1];
        port groomingControl : MotorOutputPort;
    }

    public part def VestibularSystem {
        attribute equilibriumSensitivity : Real [1];
        port balanceData : SensoryInputPort;
    }

    // System Definition
    public part def Cat {
        attribute weight : Real [1];
        attribute age : Real [1];
        attribute name : Real [1];
        attribute breedType : Real [1];

        // Sensory System
        part brain : Brain {
            satisfy REQ_005;
            satisfy REQ_006;
            satisfy REQ_007;
        }

        part eyes : Eyes [2] {
            satisfy REQ_005;
        }

        part ears : Ears [2] {
            satisfy REQ_006;
        }

        part whiskers : Whiskers {
            satisfy REQ_007;
        }

        part nose : Nose {
            satisfy REQ_003;
        }

        part vestibularsystem : VestibularSystem {
            satisfy REQ_001;
            satisfy REQ_013;
        }

        // Musculoskeletal System
        part frontLegs : Legs [2] {
            satisfy REQ_002;
            satisfy REQ_004;
            satisfy REQ_012;
        }

        part backLegs : Legs [2] {
            satisfy REQ_002;
            satisfy REQ_004;
            satisfy REQ_012;
        }

        part tail : Tail {
            satisfy REQ_001;
        }

        // Communication System
        part vocalcords : VocalCords {
            satisfy REQ_010;
        }

        part scentglands : ScentGlands {
            satisfy REQ_011;
        }

        // Metabolic Systems
        part digestivesystem : DigestiveSystem;

        part fur : Fur {
            satisfy REQ_008;
        }

        part tongue : Tongue {
            satisfy REQ_009;
        }

        // Neural Connections (Sensory → Brain)
        connect eyes.visualData to brain.sensoryIn;
        connect ears.audioData to brain.sensoryIn;
        connect whiskers.tactileData to brain.sensoryIn;
        connect nose.smellData to brain.sensoryIn;
        connect vestibularsystem.balanceData to brain.sensoryIn;

        // Motor Control (Brain → Effectors)
        connect brain.motorOut to frontLegs.motorControl;
        connect brain.motorOut to backLegs.motorControl;
        connect brain.motorOut to tail.balanceControl;
        connect brain.motorOut to tongue.groomingControl;
        connect brain.cognitionSignal to vocalcords.vocalizationOut;

        // Metabolic Regulation
        connect digestivesystem.nutrientIntake to fur.thermalRegulation;
        connect tongue.groomingControl to fur.thermalRegulation;
    }

    // System Instance
    public part whiskers : Cat;
}
