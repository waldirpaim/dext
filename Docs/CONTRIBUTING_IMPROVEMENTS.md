# Workflow for Implementing Improvements

This document outlines the standard process for contributing technical improvements to the Dext Framework. Following these steps ensures architectural consistency, high performance, and long-term maintainability.

---

## Phase 1: Technical Analysis

Before writing any code, it is essential to understand the target area and plan the changes.

1.  **Locate the target code:** Identify all units affected. Understand the current architecture, dependencies, and public contracts (interfaces/methods).
2.  **Check existing tests:** Search the `Tests/` directory for any current unit tests covering the functionality you plan to modify.
3.  **Create a Proposal:** If you are proposing a major change, open a Discussion or an Issue with a brief plan covering:
    *   The problem or opportunity.
    *   The proposed technical solution.
    *   Potential breaking changes.
    *   Required tests.

---

## Phase 2: Implementation Standards

When coding for the Dext Framework, adhere to the following rules:

*   **Language:** Use English for all source code elements (unit names, variables, parameters, comments, and XML Documentation).
*   **Coding Style:**
    *   Follow the project's established patterns (e.g., proper indentation, naming conventions).
    *   **Rule:** Do NOT use the `L` prefix for local variables.
    *   Maintain all existing XML Documentation comments.
*   **Performance First:** Always consider the "Zero-Allocation" philosophy. Use `TSpan<T>` or direct memory operations where possible to avoid unnecessary allocations.
*   **Documentation:** Every new or modified public member **must** include full XML Documentation:
    ```pascal
    /// <summary>
    ///   Brief description of the method.
    /// </summary>
    /// <param name="AParam">Description.</param>
    /// <returns>Description.</returns>
    ```

---

## Phase 3: Testing (Dext Testing)

Improvements are only accepted if accompanied by robust unit tests.

1.  **Use the Dext Testing engine:** Write tests using the internal fluent API (`Dext.Testing`, `Dext.Assertions`).
2.  **Coverage Checklist:**
    *   **Happy Path:** Main scenario works as expected.
    *   **Edge Cases:** Handle nil, empty strings, out-of-range values, etc.
    *   **Error Handling:** Verify that the correct exceptions are raised when expected.
3.  **Memory Management:** Ensure there are no memory leaks. We recommend running tests in the IDE with FastMM4 (FullDebugMode) enabled.

---

## Phase 4: Documentation Updates

1.  **Update Features Index:** If the improvement adds a new capability or changes an existing one, update the [Features Implemented Index](../Docs/Features_Implemented_Index.md).
2.  **Keep it concise:** Technical descriptions should be brief and focus on the *what* and *how*.

---

## Phase 5: Commit and Pull Request

We follow a simplified version of Conventional Commits for the git history.

*   **Format:** `<type>: <concise description>`
*   **Types:**
    *   `feat`: New functionality.
    *   `fix`: Bug fix or robustness improvement.
    *   `perf`: Performance optimization.
    *   `refactor`: Structural changes without altering behavior.
    *   `test`: Adding or updating tests.
    *   `docs`: Documentation-only changes.

---

**Thank you for helping us build the best full-stack framework for Delphi!**
