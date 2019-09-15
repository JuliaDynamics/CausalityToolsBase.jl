module CausalityToolsBase
	import ChaosTools: non0hist
	import StaticArrays: MVector, SVector
	import DelayEmbeddings: AbstractDataset, Dataset

	include("discretization/discretization.jl")
	include("reconstruction/custom_reconstruction.jl")
	include("dimension_estimation.jl")
	include("simplex_intersections.jl")
	
	include("kerneldensity/kerneldensity.jl")
	include("mutual_information/mutualinformation.jl") # must be loaded after kerneldensity
	
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