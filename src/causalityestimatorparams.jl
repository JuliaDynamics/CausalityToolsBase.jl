
"""
CausalityEstimatorParams

An abstract type that is the supertype of all causality estimator parameter types 
in the `CausalityTools` ecosystem. 

The naming convention for abstract subtypes is `SomeEstimatorParams`. Examples of
the type hierarchy of abstract estimator types could be:

- `TransferEntropyEstimatorParams <: CausalityEstimatorParams`
- `CrossMappingEstimatorParams <: CausalityEstimatorParams`


Subtypes of those abstract types are named according to the specific algorithm. Examples
of complete type hierachies for specific estimator parameter types could be:

- `VisitationFrequencyParams <: TransferEntropyEstimatorParams <: CausalityEstimatorParams`.
- `TransferOperatorGridParams <: TransferEntropyEstimatorParams <: CausalityEstimatorParams`.
- `SimpleCrossMapParams <: CrossMappingEstimatorParams <: CausalityEstimatorParams`.
- `ConvergentCrossMapParams <: CrossMappingEstimatorParams <: CausalityEstimatorParams`.
- `JointDistanceDistributionParams <: JointDistanceDistributionEstimatorParams <: CausalityEstimatorParams`.
"""
abstract type CausalityEstimatorParams end

export CausalityEstimatorParams