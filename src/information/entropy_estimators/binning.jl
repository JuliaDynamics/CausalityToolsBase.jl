

import Statistics
import ..RectangularBinning

include("../binning_heuristics.jl")

export 
    BinningEntropyEstimator,
    TriangulationEntropyEstimator,
    RectangularEntropyEstimator

"""
    BinningEntropyEstimator <: EntropyEstimator

The supertype of all binning-based entropy estimators.
"""
abstract type BinningEntropyEstimator <: EntropyEstimator end

""" 
    TriangulationEntropyEstimator <: EntropyEstimator
    
Supertype of all triangulation-based entropy estimators.
"""
abstract type TriangulationEntropyEstimator <: BinningEntropyEstimator end

""" 
    TriangulationEntropyEstimator <: EntropyEstimator
    
Supertype of all triangulation-based entropy estimators.
"""
abstract type RectangularEntropyEstimator <: BinningEntropyEstimator end


Base.@kwdef struct VisitationFrequency <: BinningEntropyEstimator
    """ The base of the logarithm usen when computing transfer entropy. """
    b::Number = 2.0

    """ The summary statistic to use if multiple discretization schemes are given """
    summary_statistic::Function = Statistics.mean

    """ The discretization scheme. """
    binning::Union{RectangularBinning, Vector{RectangularBinning}, BinningHeuristic} = ExtendedPalusLimit()

    VisitationFrequency(b, summary_statistic, binning) = new(b, summary_statistic, binning)
end