using Reexport

@reexport module Information
    # Useful internally used functions and types that should be exposed to user.
    import DelayEmbeddings: GeneralizedEmbedding, genembed, Dataset
    export GeneralizedEmbedding, genembed, Dataset

    # Utility methods
    include("utils.jl")

    # Entropy estimators
    include("entropy_estimators/abstract.jl")
    include("entropy_estimators/binning.jl")
    include("entropy_estimators/symbolic.jl")
    include("entropy_estimators/knn.jl")
    include("entropy_estimators/kde.jl")

    include("entropy.jl")

    include("mutualinformation.jl")
end