# Python SPA Adapter System Architecture

## Overview

This document describes the SysML v2 architecture model for the Python SPA Adapter system - a comprehensive toolkit for generating, parsing, validating, and visualizing SysML v2 architectures.

## Architecture Files

- **SysML Model:** `data/architectures/python_spa_adapter_system.sysml`
- **BDD Diagram:** `data/architectures/python_spa_adapter_system_bdd.puml`
- **BDD View:** https://www.plantuml.com/plantuml/png/dLThRzis5FskNq4O69fqS94cpMD2PzI9rwA3itbM5c0OXe6HhcKkDAcILqwzOVzzbtfOiam_i7vIoSDpxliw7onoW_b21lPPg8mRlc2nNcHQWS88LnAOWHYvIYMq87RE4_qYLCfcNDhsZT6vIc9j51XsqoQLt5hsJy3etosFdzC2UAUbDk_VFqaTFmy6R2pIEKRFgrkPWnzfu4ik32p8kXh_6qYfNqguDWcO0ifk9RqD_Wq254XUJ5Ouruf5ao4R9Zn3CgzF6D9b8vW99L3GzKZmr5bxSZiQdGR1gos43Kf7Y2S2ioIMnlhIkM_PN5iCMOI6ubCTPThGqMU5a8Afpd1kW9DVkMfTaRsLmChUZoVSMA-4pJD72KcqKiY_rcg_l_wZm_09A14SjOz4vvZb-56R1U_QArJYyY_-XbscFN8faXt4o_AEmZND9TYsTIK0ZD7cWVotSosJa4s1ouP_8hd2N-_7Ko0hZDV_fCpJmohpqgjO9tGobAas0kUBjNThZGUm6EK2mKEETDT9IvL5UZdb29N1vM6igGfu2XCmCRWt7MUA53evwv6298KxRg6uxyhbIf0VtRiry-FZBbPR58MNqyA2WYjYx-LCKBQgn4BYaImEJ97PdHwf9DD2eLSWrYhEZQ7yh7PvDU98yS29o40AvKjFneNnfWSDfovLQPH9WHivQWgoVRVM79fuJgKGOsvWNyEavPsZ8IsINdNQPicD05oDOGbok-O-KdWZOgPYyIMjl9bmd7TOPqM7HcNBUrkz76uqa-hHjgPtCspQp4mRwAU_o57Mc_xmI__ix6sFSSle-q_wPjtnMfg6y1NPzwntdrkiGm1bICjHm9Rd1IZdiYgzdZDjK-cyfNH-Z58rugXYtGAXUgpYm4uMr1JIHLl0YptrQ5sqj2wEqQhg0ohp6LV9kbEiH-1TI-3T0O7Xv3DRE94dg4P-t_8PU5WlMwoN1rYdRYVsgH8orrHMM7HDnQedYOVzgiL-TO3TDISbm8t7mdHE_K4rpGRVdNsp7dWUZUkMnlN_AATwyjVptHVxcvR6pG6DQfZGEcC_HZ__DAvAg61zvOeNOS7ktCyTM-x_aqIudpjKR7sQCpIeq8KNQQvOHZ6GoMcmrMkl-_q1wr4dDRy9GcOpNdxlmxTMVEZax65uCvx2EdZwuADcLuTrgUzzjBM0GogiydFFgsQbXiKABRxtgRGsO-r-yRyzR-gTHtui3s6tbbL8TR1vjETrTm-5BDaysVFMlqz2nkdyqn59Qo-Ai5uChcABlXocgO6qS29eOhuZh4B5Ca_0-f1DCFUXl66iu9lBXKM4iZCU5wOrtV3cpM0zAqFgM5l0LhISsXtGeDuUXReu2dNfGpKvEI3g0vuV2_HADwsusvEjzckWrnreawy6SzN1T2kvGTvqaFwwtHsZTftk3b3mWVnmVs7-1m==

## System Components

### Core Processing Components

#### 1. SPAServer
**Purpose:** Python HTTP server providing REST API and static file serving

**Attributes:**
- `host`: Server bind address (String)
- `port`: Server port number (Integer)
- `threadCount`: Number of worker threads (Integer)

**Interfaces:**
- `httpIn`: HTTP request input port
- `dataOut`: Data response output port
- `fileIn`: File access port for serving static content

**Satisfies:** REQ_004 (Thread-safe API)

#### 2. SysMLParser
**Purpose:** Parses SysML v2 textual syntax to intermediate representation (IR/JSON)

**Attributes:**
- `supportedSyntax`: List of supported SysML constructs (String[*])

**Interfaces:**
- `fileIn`: Input port for .sysml files
- `dataOut`: Output port for parsed IR/JSON
- `validationOut`: Validation results output

**Satisfies:** REQ_001, REQ_003, REQ_005 (Valid syntax, validation, round-trip)

#### 3. SysMLGenerator
**Purpose:** Generates SysML v2 textual syntax from intermediate representation

**Attributes:**
- `outputFormat`: Output format specification (String)
- `indentSize`: Indentation size for generated code (Integer)

**Interfaces:**
- `dataIn`: Input port for IR/JSON
- `fileOut`: Output port for generated .sysml files
- `validationIn`: Validation feedback input

**Satisfies:** REQ_001, REQ_002, REQ_005 (Valid syntax, separated format, round-trip)

#### 4. SysMLValidator
**Purpose:** Validates SysML syntax and semantic correctness

**Attributes:**
- `validationRules`: Set of validation rules (String[*])
- `errorThreshold`: Acceptable error rate threshold (Real)

**Interfaces:**
- `fileIn`: Input port for .sysml files to validate
- `validationOut`: Validation results output
- `reportOut`: Detailed validation report output

**Satisfies:** REQ_003 (Syntax and semantic validation)

#### 5. PlantUMLRenderer
**Purpose:** Generates PlantUML diagrams (BDD/IBD) from SysML architectures

**Attributes:**
- `diagramTypes`: Supported diagram types (String[*])
- `encodingAlgorithm`: PlantUML URL encoding method (String)

**Interfaces:**
- `dataIn`: Input port for architecture data
- `renderOut`: Rendered diagram output
- `urlOut`: PlantUML URL output

**Satisfies:** REQ_007 (Valid PlantUML generation)

### Testing Infrastructure

#### 6. TestSuite
**Purpose:** Comprehensive test infrastructure coordinator

**Attributes:**
- `testCount`: Total number of tests (Integer)
- `passRate`: Test pass rate percentage (Real)
- `coveragePercent`: Code coverage percentage (Real)

**Interfaces:**
- `testIn`: Test results input from sub-suites
- `reportOut`: Aggregated test report output

**Satisfies:** REQ_006 (>90% code coverage)

#### 7. ParserTests
**Purpose:** Parser functionality test suite (48 tests)

**Attributes:**
- `edgeCaseTests`: Number of edge case tests (Integer)
- `unicodeTests`: Number of Unicode handling tests (Integer)

**Interfaces:**
- `testOut`: Test results output to main suite

#### 8. VVTests
**Purpose:** Verification and validation test suite (16 tests, 202 files)

**Attributes:**
- `syntaxTests`: Number of syntax validation tests (Integer)
- `semanticTests`: Number of semantic validation tests (Integer)
- `filesValidated`: Number of files validated (Integer)

**Interfaces:**
- `testOut`: Test results output to main suite

#### 9. IntegrationTests
**Purpose:** SPA integration and API test suite (43 tests)

**Attributes:**
- `endpointTests`: Number of API endpoint tests (Integer)
- `concurrencyTests`: Number of concurrency tests (Integer)

**Interfaces:**
- `testOut`: Test results output to main suite

### Data Pipeline

#### 10. DatasetPipeline
**Purpose:** Generates training pairs for ML fine-tuning

**Attributes:**
- `pairCount`: Number of training pairs generated (Integer)
- `trainingSplit`: Training data split ratio (Real)
- `validationSplit`: Validation data split ratio (Real)

**Interfaces:**
- `dataIn`: Architecture data input
- `fileOut`: JSONL formatted output

**Satisfies:** REQ_008 (JSONL format output)

#### 11. ArchitectureGenerator
**Purpose:** Generates sample SysML architectures

**Attributes:**
- `generationStrategy`: Generation algorithm approach (String)
- `varietyLevel`: Diversity of generated architectures (String)

**Interfaces:**
- `dataOut`: Generated architecture data output
- `fileOut`: Generated .sysml file output

**Satisfies:** REQ_001 (Valid SysML v2 generation)

#### 12. FileStorage
**Purpose:** Persistent storage for architectures and training pairs

**Attributes:**
- `storagePath`: Base storage directory path (String)
- `formatSupport`: Supported file formats (String[*])

**Interfaces:**
- `fileIn`: File write input
- `fileOut`: File read output

**Satisfies:** REQ_002 (Separated format support)

## System Requirements

### REQ_001: Valid SysML v2 Generation
**Text:** Must generate valid SysML v2 textual syntax compliant with official specification

**Satisfied by:**
- SysMLParser
- SysMLGenerator
- ArchitectureGenerator

### REQ_002: Separated Format Support
**Text:** Must support separated format with model and view files

**Satisfied by:**
- SysMLGenerator
- FileStorage

### REQ_003: Validation
**Text:** Must validate syntax and semantic correctness of generated SysML

**Satisfied by:**
- SysMLParser
- SysMLValidator

### REQ_004: Thread Safety
**Text:** API must be thread-safe for concurrent requests

**Satisfied by:**
- SPAServer

### REQ_005: Round-trip Consistency
**Text:** Must maintain round-trip consistency: IR → .sysml → IR preserves all data

**Satisfied by:**
- SysMLParser
- SysMLGenerator

### REQ_006: Test Coverage
**Text:** Test suite must achieve >90% code coverage

**Satisfied by:**
- TestSuite

### REQ_007: PlantUML Generation
**Text:** Must generate valid PlantUML for BDD and IBD diagrams

**Satisfied by:**
- PlantUMLRenderer

### REQ_008: Dataset Format
**Text:** Dataset pipeline must produce training pairs in JSONL format

**Satisfied by:**
- DatasetPipeline

## Data Flows

### 1. Generation Flow: Natural Language → .sysml
```
ArchitectureGenerator → SysMLGenerator → FileStorage → SysMLValidator
```

### 2. Parse Flow: .sysml → IR
```
FileStorage → SysMLParser → (IR/JSON output)
```

### 3. Round-trip Validation Flow
```
SysMLParser → SysMLGenerator → SysMLParser (consistency check)
```

### 4. Diagram Generation Flow
```
SysMLParser → PlantUMLRenderer → SPAServer (URL output)
```

### 5. API Service Flow
```
SPAServer ← FileStorage ← SysMLParser/SysMLGenerator
```

### 6. Dataset Pipeline Flow
```
ArchitectureGenerator → DatasetPipeline → FileStorage (JSONL)
```

### 7. Test Execution Flow
```
ParserTests/VVTests/IntegrationTests → TestSuite → SPAServer (reports)
```

## Key Architectural Patterns

### Separation of Concerns
- **Parsing** (SysMLParser) vs **Generation** (SysMLGenerator) are distinct components
- **Validation** (SysMLValidator) is independent and reusable
- **Testing** infrastructure is modular (Parser, V&V, Integration)

### Pipeline Architecture
- Clear data flow: Natural language → IR → .sysml → validation → diagrams
- Each stage can operate independently
- Supports both forward generation and reverse parsing

### Layered Architecture
1. **Presentation Layer:** SPAServer (REST API + static files)
2. **Business Logic Layer:** Parser, Generator, Validator, Renderer
3. **Data Layer:** FileStorage
4. **Quality Assurance Layer:** TestSuite with specialized test components

### Port-Based Communication
- Components communicate through typed ports (HTTPPort, DataPort, FilePort, etc.)
- Loose coupling enables component replacement and testing

## Validation Results

✅ **Architecture Validation Status:**
- **Syntax Errors:** 0
- **Semantic Errors:** 0
- **Warnings:** 0
- **Requirements Coverage:** 8/8 requirements satisfied
- **Component Count:** 12 components
- **Connection Count:** 18 data flows

## Usage

### Viewing the Architecture

```bash
# Parse the architecture
python3 spa/sysml_parser.py data/architectures/python_spa_adapter_system.sysml

# Validate the architecture
python3 -c "
from pathlib import Path
from tests.test_sysml_validation import SysMLValidator
validator = SysMLValidator()
issues = validator.validate_file(Path('data/architectures/python_spa_adapter_system.sysml'))
print(f'Errors: {sum(1 for i in issues if i.severity == \"ERROR\")}')
"

# View the BDD diagram
open https://www.plantuml.com/plantuml/png/...
```

### Generating Diagrams

```bash
# Start the SPA server
python3 spa/server.py

# Access BDD diagram via API
curl http://localhost:8765/api/diagrams/python_spa_adapter_system.sysml?type=bdd

# Access IBD diagram via API
curl http://localhost:8765/api/diagrams/python_spa_adapter_system.sysml?type=ibd
```

## References

- **Test Suite Summary:** `TEST_SUITE_SUMMARY.md`
- **Testing Quick Reference:** `TESTING_QUICK_REFERENCE.md`
- **SysML v2 Specification:** https://github.com/systems-modeling/sysml-v2-release
- **Project README:** `README.md`

---

**Architecture Version:** 1.0  
**Created:** 2026-05-27  
**Last Updated:** 2026-05-27  
**Status:** ✅ Validated and Operational
