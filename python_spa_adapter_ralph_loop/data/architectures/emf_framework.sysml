package EclipseModelingFramework {

    import ScalarValues::*;

    // EMF Architecture
    // Domain: modeling framework

    // Requirements - Atomic requirements for EMF
    public requirement REQ_001 {
        doc "The framework shall define metamodels using Ecore."
    }

    public requirement REQ_002 {
        doc "The framework shall serialize models to XMI format."
    }

    public requirement REQ_003 {
        doc "The framework shall deserialize XMI to model instances."
    }

    public requirement REQ_004 {
        doc "The framework shall validate model instances against metamodels."
    }

    public requirement REQ_005 {
        doc "The framework shall generate Java code from metamodels."
    }

    public requirement REQ_006 {
        doc "The framework shall notify observers of model changes."
    }

    public requirement REQ_007 {
        doc "The framework shall manage model resources."
    }

    public requirement REQ_008 {
        doc "The framework shall resolve cross-model references."
    }

    public requirement REQ_009 {
        doc "The framework shall support model transformation."
    }

    public requirement REQ_010 {
        doc "The framework shall provide adapter-based extensibility."
    }

    public requirement REQ_011 {
        doc "The framework shall support reflective model access."
    }

    public requirement REQ_012 {
        doc "The framework shall persist models efficiently."
    }

    public requirement REQ_013 {
        doc "The framework shall support bidirectional references."
    }

    public requirement REQ_014 {
        doc "The framework shall enforce containment hierarchies."
    }

    public requirement REQ_015 {
        doc "The framework shall support dynamic EMF for runtime metamodels."
    }

    // Port Definitions
    public port def MetamodelPort;
    public port def SerializationPort;
    public port def ValidationPort;
    public port def NotificationPort;
    public port def ResourcePort;
    public port def CodeGenPort;
    public port def AdapterPort;
    public port def TransformationPort;

    // Component Definitions
    public part def EcoreMetamodel {
        attribute classCount : Real [1];
        attribute packageCount : Real [1];
        attribute supportsInheritance : Real [1];
        port metamodelOut : MetamodelPort;
        port validationIn : ValidationPort;
    }

    public part def EClass {
        attribute name : Real [1];
        attribute isAbstract : Real [1];
        attribute isInterface : Real [1];
        port classDefinition : MetamodelPort;
    }

    public part def EAttribute {
        attribute name : Real [1];
        attribute type : Real [1];
        attribute multiplicity : Real [1];
        port attributeDefinition : MetamodelPort;
    }

    public part def EReference {
        attribute name : Real [1];
        attribute isContainment : Real [1];
        attribute isBidirectional : Real [1];
        port referenceDefinition : MetamodelPort;
    }

    public part def XMIResource {
        attribute encoding : Real [1];
        attribute version : Real [1];
        port serializeOut : SerializationPort;
        port deserializeIn : SerializationPort;
        port resourceMgmt : ResourcePort;
    }

    public part def ResourceSet {
        attribute uriMappings : Real [1];
        attribute resourceCount : Real [1];
        port resourceAccess : ResourcePort;
        port referenceResolution : ResourcePort;
    }

    public part def EValidator {
        attribute ruleCount : Real [1];
        attribute severity : Real [1];
        port validationOut : ValidationPort;
        port metamodelIn : MetamodelPort;
    }

    public part def Diagnostic {
        attribute severity : Real [1];
        attribute message : Real [1];
        attribute location : Real [1];
        port diagnosticOut : ValidationPort;
    }

    public part def NotificationChain {
        attribute eventType : Real [1];
        attribute oldValue : Real [1];
        attribute newValue : Real [1];
        port notifyOut : NotificationPort;
    }

    public part def EAdapter {
        attribute targetClass : Real [1];
        port adaptIn : AdapterPort;
        port notificationReceive : NotificationPort;
    }

    public part def AdapterFactory {
        attribute adapterCount : Real [1];
        port createAdapter : AdapterPort;
    }

    public part def EcoreUtil {
        attribute copySupport : Real [1];
        attribute resolveSupport : Real [1];
        port utilityOps : MetamodelPort;
        port crossRefResolver : ResourcePort;
    }

    public part def CodeGenerator {
        attribute targetLanguage : Real [1];
        attribute templateEngine : Real [1];
        port codeGenOut : CodeGenPort;
        port metamodelIn : MetamodelPort;
    }

    public part def GenModel {
        attribute packageName : Real [1];
        attribute basePackage : Real [1];
        port genConfig : CodeGenPort;
    }

    public part def ReflectiveAPI {
        attribute dynamicEObjectSupport : Real [1];
        port reflectiveAccess : MetamodelPort;
    }

    public part def EContentAdapter {
        attribute treeTraversal : Real [1];
        port contentNotification : NotificationPort;
        port adapterMgmt : AdapterPort;
    }

    public part def TransformationEngine {
        attribute ruleCount : Real [1];
        attribute traceabilitySupport : Real [1];
        port transformIn : TransformationPort;
        port transformOut : TransformationPort;
    }

    // System Definition
    public part def EMFCore {
        attribute version : Real [1];
        attribute pluginId : Real [1];
        attribute licenseType : Real [1];

        // Metamodel Layer
        part ecoremetamodel : EcoreMetamodel {
            satisfy REQ_001;
            satisfy REQ_011;
        }

        part eclass : EClass [1..*] {
            satisfy REQ_001;
        }

        part eattribute : EAttribute [1..*] {
            satisfy REQ_001;
        }

        part ereference : EReference [1..*] {
            satisfy REQ_001;
            satisfy REQ_013;
            satisfy REQ_014;
        }

        // Serialization Layer
        part xmiresource : XMIResource {
            satisfy REQ_002;
            satisfy REQ_003;
            satisfy REQ_012;
        }

        part resourceset : ResourceSet {
            satisfy REQ_007;
            satisfy REQ_008;
        }

        // Validation Layer
        part evalidator : EValidator {
            satisfy REQ_004;
        }

        part diagnostic : Diagnostic {
            satisfy REQ_004;
        }

        // Notification System
        part notificationchain : NotificationChain {
            satisfy REQ_006;
        }

        part econtentadapter : EContentAdapter {
            satisfy REQ_006;
            satisfy REQ_010;
        }

        // Adapter Framework
        part eadapter : EAdapter [1..*] {
            satisfy REQ_010;
        }

        part adapterfactory : AdapterFactory {
            satisfy REQ_010;
        }

        // Utility Layer
        part ecoreutil : EcoreUtil {
            satisfy REQ_008;
            satisfy REQ_009;
        }

        // Code Generation
        part codegenerator : CodeGenerator {
            satisfy REQ_005;
        }

        part genmodel : GenModel {
            satisfy REQ_005;
        }

        // Reflective Access
        part reflectiveapi : ReflectiveAPI {
            satisfy REQ_011;
            satisfy REQ_015;
        }

        // Transformation Support
        part transformationengine : TransformationEngine {
            satisfy REQ_009;
        }

        // Metamodel Connections
        connect eclass.classDefinition to ecoremetamodel.metamodelOut;
        connect eattribute.attributeDefinition to ecoremetamodel.metamodelOut;
        connect ereference.referenceDefinition to ecoremetamodel.metamodelOut;

        // Serialization Connections
        connect ecoremetamodel.metamodelOut to xmiresource.serializeOut;
        connect xmiresource.deserializeIn to ecoremetamodel.metamodelOut;
        connect xmiresource.resourceMgmt to resourceset.resourceAccess;

        // Validation Connections
        connect ecoremetamodel.validationIn to evalidator.validationOut;
        connect evalidator.metamodelIn to ecoremetamodel.metamodelOut;
        connect evalidator.validationOut to diagnostic.diagnosticOut;

        // Notification Connections
        connect ecoremetamodel.metamodelOut to notificationchain.notifyOut;
        connect notificationchain.notifyOut to eadapter.notificationReceive;
        connect econtentadapter.contentNotification to notificationchain.notifyOut;

        // Adapter Framework Connections
        connect adapterfactory.createAdapter to eadapter.adaptIn;
        connect econtentadapter.adapterMgmt to eadapter.adaptIn;

        // Utility Connections
        connect ecoreutil.utilityOps to ecoremetamodel.metamodelOut;
        connect ecoreutil.crossRefResolver to resourceset.referenceResolution;

        // Code Generation Connections
        connect codegenerator.metamodelIn to ecoremetamodel.metamodelOut;
        connect genmodel.genConfig to codegenerator.codeGenOut;

        // Reflective API Connections
        connect reflectiveapi.reflectiveAccess to ecoremetamodel.metamodelOut;

        // Transformation Connections
        connect transformationengine.transformIn to ecoremetamodel.metamodelOut;
        connect transformationengine.transformOut to xmiresource.deserializeIn;
    }

    // System Instance
    public part emfFramework : EMFCore;
}
