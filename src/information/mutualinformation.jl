import StaticArrays: SVector

export mi

"""
    mi(x, y, [τ::Int=0], method::EntropyEstimator)

Compute mutual information (MI) between `x` and `y`, which can be either a time series or 
an arbitrary `Dataset`. The computation is done by decomposing the mutual information 
into marginal entropies, which are estimated using `method`, as follows:

```math
MI(x, y) = H(X) - H(Y) + H(X, Y)
```
"""
function mi end

function mi(x, y, method::SymbolicPermutation)
    length(x) == length(y) || throw(ArgumentError("length(x) must equal length(y). Got $(length(x)) and $(length(y))"))
    
    XY = combine_marginals(x, y)
    HX = entropy(x, method)
    HY = entropy(x, method)
    HXY = entropy(x, method)
    @show HX, HY, HXY
    MI = HX + HY - HXY
end