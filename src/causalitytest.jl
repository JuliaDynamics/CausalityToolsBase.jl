
"""
    CausalityTest

An abstract type that is the supertype of all causality tests in the `CausalityTools` ecosystem. 

The naming convention for abstract subtypes is `SomeMethodTest`. Examples of
the type hierarchy of abstract test types could be:

- `TransferEntropyTest <: CausalityTest`
- `CrossMappingTest <: CausalityTest`

Subtypes of those abstract types are named according to the specific algorithm. Examples
of complete type hierachies for specific causality test types could be:

- `VisitationFrequencyTest <: TransferEntropyTest <: CausalityTest`.
- `TransferOperatorGridTest <: TransferEntropyTest <: CausalityTest`.
- `CrossMappingTest <: DistanceBasedTest <: CausalityTest`.
"""
abstract type CausalityTest end

export CausalityTest
