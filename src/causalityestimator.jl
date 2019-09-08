
"""
CausalityEstimator

An abstract type that is the supertype of all causality estimators in the `CausalityTools` ecosystem.

The naming convention for abstract subtypes is `SomeEstimator`. Examples of 
abstract estimator type hierarchies could be:

- `TransferEntropyEstimator <: CausalityEstimator`
- `CrossMappingEstimator <: CausalityEstimator`

Specific estimator types are named according to the algorithm. Examples of 
complete type hierarchies for different estimators could be:

- `VisitationFrequency <: TransferEntropyEstimator <: CausalityEstimator`.
- `TransferOperatorGrid <: TransferEntropyEstimator <: CausalityEstimator`.
- `SimpleCrossMap <: CrossMappingEstimator <: CausalityEstimator`.
- `ConvergentCrossMap <: CrossMappingEstimator <: CausalityEstimator`.
- `JointDistanceDistribution <: JointDistanceDistributionEstimator <: CausalityEstimator`.

Each estimator type, also the abstract ones, have a corresponding parameter 
type where `Test` is appending to the type name, for example 
`VisitationFrequencyTest <: TransferEntropyEstimatorTest <: CausalityEstimatorTest`.
"""
abstract type CausalityEstimator end

export CausalityEstimator