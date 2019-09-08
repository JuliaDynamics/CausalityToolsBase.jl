
"""
CausalityTest

An abstract type that is the supertype of all causality test types 
in the `CausalityTools` ecosystem. 

The naming convention for abstract subtypes is `SomeEstimatorTest`. Examples of
the type hierarchy of abstract test types could be:

- `TransferEntropyEstimatorTest <: CausalityEstimatorTest`
- `CrossMappingEstimatorTest <: CausalityEstimatorTest`


Subtypes of those abstract types are named according to the specific algorithm. Examples
of complete type hierachies for specific causality test types could be:

- `VisitationFrequencyTest <: TransferEntropyEstimatorTest <: CausalityEstimatorTest`.
- `TransferOperatorGridTest <: TransferEntropyEstimatorTest <: CausalityEstimatorTest`.
- `SimpleCrossMapTest <: CrossMappingEstimatorTest <: CausalityEstimatorTest`.
- `ConvergentCrossMapTest <: CrossMappingEstimatorTest <: CausalityEstimatorTest`.
- `JointDistanceDistributionTest <: JointDistanceDistributionEstimatorTest <: CausalityEstimatorTest`.
"""
abstract type CausalityEstimatorTest end

export CausalityEstimatorTest