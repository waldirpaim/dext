# Dext Test Runner Evolution & TestInsight Learnings

This document summarizes the technical challenges, architectural decisions, and the roadmap for the future Dext Native Test Runner, based on the integration with the TestInsight IDE plugin.

## 1. Context & Challenges
The integration with TestInsight allowed the Dext framework to be usable directly from the Delphi IDE. However, it revealed several "friction points" in how modern IDE test plugins communicate with external runners.
### Key Learnings:
*   **IPC Overhead**: Individual test reporting via IPC (Inter-Process Communication) is extremely slow when scaled. For a suite of ~100 tests, reporting skipped tests individually added **11 seconds** to execution time, while the test logic itself ran in **22ms**.
*   **Visual State Persistence**: IDE plugins often maintain a "cache" of previous results. If a runner doesn't explicitly clear or report all tests, the UI might show stale "Green" or "Red" states for tests that didn't run.
*   **Status Ambiguity**: The default behavior of many Delphi runners (where results start as `0/Passed`) causes "Discovery" modes to look like successful executions unless a neutral state (like `trNone`) is introduced.

---

## 2. Architectural Solutions Implemented

### Neutral State (trNone)
We introduced `trNone` to the `TTestResult` enum.
*   **Problem**: Without it, discovered tests were defaults to `Passed` in the internal list.
*   **Solution**: All tests start as `trNone`. Only those that actually run move to `Passed`, `Failed`, or `Skipped`.
*   **IDE Mapping**: `trNone` and `trSkipped` are both mapped to the IDE's "Skipped" status to avoid false positives.

### Silent Discovery
*   **Optimization**: During the "Discovery" phase (when the IDE asks "what tests do you have?"), we silence all listeners. This makes discovery instantaneous and prevents polluting the IDE's UI with incomplete data.

### Performance-First Filtering
*   **Decision**: We stopped reporting `trSkipped` status for tests not selected by the IDE.
*   **Result**: Reduced execution time from 11s to <100ms for single-test runs. We accepted that unselected tests might keep their previous visual state in the IDE in exchange for extreme speed.

---

## 3. The Future: Dext Native Runner

When we build our own Dext Runner (IDE Plugin or Standalone), we must implement the following concepts to surpass current limitations:

### A. The "Session" Concept (.NET style)
In the .NET world (VSTest/NUnit), execution is bound to a **Session ID**.
*   **How it works**: Every time you hit "Run", a unique Session is created.
*   **Benefit**: The runner only cares about the results of *that* session. Results from a previous session are automatically treated as "Not Run" in the UI without needing explicit "Skip" messages for every test.

### B. Batch Reporting (Bulk IPC)
*   Instead of `PostResult(Test1)`, `PostResult(Test2)`, etc., the runner should support `PostResults(ArrayOfResults)`.
*   **Scenario**: Run 1000 tests, send 1 JSON/Pipe message at the end of each fixture or the entire run. This eliminates the IPC bottleneck.

### C. True Discovery Protocol
*   Separate the **Metadata Fetch** from the **Result Report**.
*   The runner should provide a serialized tree of tests that the IDE consumes once, and then the IPC only sends `(TestID, Status, Time)`.

### D. Smart Differential Execution
*   The runner should know which files changed and prioritize running those specific tests first, a concept common in "Continuous Testing" tools (like NCrunch or Wallaby.js).

---

## 4. Current Design Constraints (Legacy IDEs)
*   **Handshake**: Always verify `bds.exe` presence to avoid unnecessary network/IPC overhead in CI environments.
*   **Filter Robustness**: Names provided by the IDE can vary (full name vs. class name). The `Matches` logic must be resilient and support partial/wildcard matching.

---

> [!TIP]
> **Performance over Perfection**: In Developer Tools, a delay of >1s for a single test execution is considered a failure. Always prioritize the "Instant Feedback Loop" (TDD) even if it means some visual state in the IDE is not perfectly synchronized.

---

More...

Test Insight, Drop Down com todos os projetos de testes disponíveis no workspace
