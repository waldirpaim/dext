# 🛠️ S07: High-Performance Type System (Optimized Reflection)

## 🎯 Objective
Replace generic RTTI/TValue interactions with a **Fast Path Type Registry** using Pointer Manipulation and specialized Type Handlers. This will significantly boost the performance of the ORM (Dext.EF), Model Binding, and JSON Serialization.

## 🏗️ Technical Architecture

### 1. Type Handler Registry
A centralized registry (`TTypeRegistry`) that stores specialized handlers for core types (Integer, string, TDateTime, UUID) and Dext Smart Types (`Prop<T>`, `Nullable<T>`, `Lazy<T>`).

- **Interface Based**: If a type is registered, its handler is used instead of RTTI.
- **Pointer-to-Pointer**: Handlers operate directly on memory addresses to avoid $TValue$ boxing overhead.

```pascal
type
  TValueSetter = procedure(const AInstance: Pointer; const AValue: Pointer);
  TValueGetter = function(const AInstance: Pointer): TValue; // Or specialized pointer return
```

### 2. Specialized Metadata
Extend `TTypeMetadata` to include:
- **FastSetter**: A pre-compiled or registered function for direct value injection.
- **FastGetter**: A direct accessor for the underlying value.
- **Offset-Based Access**: For Smart Properties, cache the memory offset of `FValue` to avoid RTTI lookup on every call.

### 3. Hyper-Fast Activator
Refactor `TActivator` to use a global factory cache.
- **Constructor Pointers**: Cache the address of the `Create` constructor for common entities.
- **Record Zeroing**: Use `FillChar` or `Default(T)` specialization instead of RTTI for record initialization.

## 🚀 Performance Targets
- **ORM Hydration**: 3x to 5x faster than current RTTI-based implementation.
- **Model Binding**: Reduce CPU cycles in high-concurrency Web scenarios.
- **Zero-Allocation**: Minimal memory allocations during property access.

## 📋 Implementation Plan
1.  **Core Discovery**: Audit `Sources/Core` for all RTTI calls (`GetValue`, `SetValue`).
2.  **Base Registry**: Implement `Dext.Core.TypeRegistry.pas`.
3.  **Fast Path**: Register specialized handlers for `Integer`, `string`, `Boolean`, `Double`, `TDateTime`.
4.  **Smart Prop Specialization**: Create hard-coded handlers for `Nullable<T>` and `Prop<T>`.
5.  **Refactor**: Update `TReflection` to prioritize the registry before falling back to RTTI.

---
*Created: April 2026 - The "Delirium-Inspired" Performance Push*
