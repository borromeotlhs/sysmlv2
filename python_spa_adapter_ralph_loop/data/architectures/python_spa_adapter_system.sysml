package PythonSPAAdapterSystem {
    import ScalarValues::*;

    // Port type definitions
    port def HTTPPort;
    port def DataPort;
    port def FilePort;
    port def ValidationPort;
    port def RenderPort;
    port def TestPort;

    // Requirements
    public requirement REQ_001 {
        doc /* Must generate valid SysML v2 textual syntax compliant with official specification */
    }

    public requirement REQ_002 {
        doc /* Must support separated format with model and view files */
    }

    public requirement REQ_003 {
        doc /* Must validate syntax and semantic correctness of generated SysML */
    }

    public requirement REQ_004 {
        doc /* API must be thread-safe for concurrent requests */
    }

    public requirement REQ_005 {
        doc /* Must maintain round-trip consistency: IR to .sysml to IR preserves all data */
    }

    public requirement REQ_006 {
        doc /* Test suite must achieve >90% code coverage */
    }

    public requirement REQ_007 {
        doc /* Must generate valid PlantUML for BDD and IBD diagrams */
    }

    public requirement REQ_008 {
        doc /* Dataset pipeline must produce training pairs in JSONL format */
    }

    // Component definitions
    public part def SPAServer {
        doc /* Python HTTP server providing REST API and static file serving */
        attribute host : String [1];
        attribute port : Integer [1];
        attribute threadCount : Integer [1];
        port httpIn : HTTPPort;
        port dataOut : DataPort;
        port fileIn : FilePort;
    }

    public part def SysMLParser {
        doc /* Parses SysML v2 textual syntax to intermediate representation */
        attribute supportedSyntax : String [1..*];
        port fileIn : FilePort;
        port dataOut : DataPort;
        port validationOut : ValidationPort;
    }

    public part def SysMLGenerator {
        doc /* Generates SysML v2 textual syntax from intermediate representation */
        attribute outputFormat : String [1];
        attribute indentSize : Integer [1];
        port dataIn : DataPort;
        port fileOut : FilePort;
        port validationIn : ValidationPort;
    }

    public part def SysMLValidator {
        doc /* Validates SysML syntax and semantics */
        attribute validationRules : String [1..*];
        attribute errorThreshold : Real [1];
        port fileIn : FilePort;
        port validationOut : ValidationPort;
        port reportOut : DataPort;
    }

    public part def PlantUMLRenderer {
        doc /* Generates PlantUML diagrams from SysML architectures */
        attribute diagramTypes : String [1..*];
        attribute encodingAlgorithm : String [1];
        port dataIn : DataPort;
        port renderOut : RenderPort;
        port urlOut : DataPort;
    }

    public part def TestSuite {
        doc /* Comprehensive test infrastructure for validation */
        attribute testCount : Integer [1];
        attribute passRate : Real [1];
        attribute coveragePercent : Real [1];
        port testIn : TestPort;
        port reportOut : DataPort;
    }

    public part def ParserTests {
        doc /* Tests for SysML parser functionality */
        attribute edgeCaseTests : Integer [1];
        attribute unicodeTests : Integer [1];
        port testOut : TestPort;
    }

    public part def VVTests {
        doc /* Verification and validation test suite */
        attribute syntaxTests : Integer [1];
        attribute semanticTests : Integer [1];
        attribute filesValidated : Integer [1];
        port testOut : TestPort;
    }

    public part def IntegrationTests {
        doc /* SPA integration and API tests */
        attribute endpointTests : Integer [1];
        attribute concurrencyTests : Integer [1];
        port testOut : TestPort;
    }

    public part def DatasetPipeline {
        doc /* Generates training pairs for ML fine-tuning */
        attribute pairCount : Integer [1];
        attribute trainingSplit : Real [1];
        attribute validationSplit : Real [1];
        port dataIn : DataPort;
        port fileOut : FilePort;
    }

    public part def ArchitectureGenerator {
        doc /* Generates sample SysML architectures */
        attribute generationStrategy : String [1];
        attribute varietyLevel : String [1];
        port dataOut : DataPort;
        port fileOut : FilePort;
    }

    public part def FileStorage {
        doc /* Persistent storage for architectures and pairs */
        attribute storagePath : String [1];
        attribute formatSupport : String [1..*];
        port fileIn : FilePort;
        port fileOut : FilePort;
    }

    // Main system definition
    public part def PythonSPAAdapter {
        doc /* Complete Python-based SPA adapter system for SysML v2 generation and validation */

        // Core processing components
        part spaServer : SPAServer {
            satisfy REQ_004;
        }

        part parser : SysMLParser {
            satisfy REQ_001;
            satisfy REQ_003;
            satisfy REQ_005;
        }

        part generator : SysMLGenerator {
            satisfy REQ_001;
            satisfy REQ_002;
            satisfy REQ_005;
        }

        part validator : SysMLValidator {
            satisfy REQ_003;
        }

        part renderer : PlantUMLRenderer {
            satisfy REQ_007;
        }

        // Testing infrastructure
        part testSuite : TestSuite {
            satisfy REQ_006;
        }

        part parserTests : ParserTests;
        part vvTests : VVTests;
        part integrationTests : IntegrationTests;

        // Data pipeline
        part datasetPipeline : DatasetPipeline {
            satisfy REQ_008;
        }

        part archGenerator : ArchitectureGenerator {
            satisfy REQ_001;
        }

        part storage : FileStorage {
            satisfy REQ_002;
        }

        // Data flow connections: Natural language → IR → .sysml → validation
        connect generator.dataIn to archGenerator.dataOut;
        connect generator.fileOut to storage.fileIn;
        connect generator.fileOut to validator.fileIn;
        connect validator.validationOut to generator.validationIn;

        // Parse flow: .sysml → parser → IR
        connect storage.fileOut to parser.fileIn;
        connect parser.dataOut to generator.dataIn;
        connect parser.validationOut to validator.validationOut;

        // Round-trip validation flow
        connect parser.dataOut to generator.dataIn;
        connect generator.fileOut to parser.fileIn;

        // PlantUML rendering flow
        connect parser.dataOut to renderer.dataIn;
        connect renderer.urlOut to spaServer.dataOut;

        // SPA API flow
        connect spaServer.fileIn to storage.fileOut;
        connect storage.fileOut to spaServer.dataOut;
        connect renderer.urlOut to spaServer.dataOut;

        // Dataset generation flow
        connect archGenerator.dataOut to datasetPipeline.dataIn;
        connect datasetPipeline.fileOut to storage.fileIn;

        // Test suite connections
        connect parserTests.testOut to testSuite.testIn;
        connect vvTests.testOut to testSuite.testIn;
        connect integrationTests.testOut to testSuite.testIn;
        connect testSuite.reportOut to spaServer.dataOut;

        // Validation feedback loops
        connect validator.reportOut to testSuite.reportOut;
        connect testSuite.reportOut to validator.fileIn;
    }

    // System instance
    part pythonSPAAdapterInstance : PythonSPAAdapter;
}
