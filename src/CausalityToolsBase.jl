module CausalityToolsBase
	import ChaosTools: non0hist
	import StaticArrays: MVector, SVector
	import DelayEmbeddings: AbstractDataset, Dataset

	# Parameter optimization 
	include("optimization/parameteroptimization.jl")

	# Discretization
	include("discretization/discretization.jl")

	# Information theory / entropy estimator interfaces
	include("Information/Information.jl")


	#include("reconstruction/custom_reconstruction.jl")
	include("dimension_estimation.jl")
	include("simplex_intersections.jl")

	# Defines supertypes for estimators and estimator parameter types
	include("causalityestimator.jl")
	include("causalitytest.jl")
	include("causality.jl")

end # module

"""
	CausalityToolsBase

A lightweight module containing data structures and algorithms used throughout the 
CausalityTools ecosystem.
"""