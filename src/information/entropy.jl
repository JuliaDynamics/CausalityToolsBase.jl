import StatsBase: entropy
export entropy, entropy!

"""
    entropy(x::Dataset, method::SymbolicPermutation)
    entropy(x::AbstractArray{T, 1}, method::SymbolicPermutation) where T
    entropy(x::AbstractArray{T, 1}, τ::Int, method::SymbolicPermutation) where T
    entropy(x::AbstractArray{T, 1}, emb::GeneralizedEmbedding, method::SymbolicPermutation) where T

Compute the permutation entropy of `x` [^BandtPompe2002]. 

- If `x` is a `D`-dimensional `Dataset`, then compute the order-`D` permutation entropy (using motifs of length `D`).
- If `x` is a time series, embed `x` at with equidistant lags `0:1:(method.m-1)`, and then compute the permutation entropy of order `method.m` (using motifs of length `method.m`).
- If `x` is a time series and a single delay reconstruction lag `τ` is provided, embed `x` at with equidistant lags `0:τ:τ*(method.m-1)`, and then compute the permutation entropy of order `method.m` (using motifs of length `method.m`).
- If `x` is a time series and a `GeneralizedEmbedding` is provided, compute the permutation entropy of the order dictated by `emb` (i.e. if `emb` gives a 5-dimensional embedding, then use motifs of length 5). This method allows for more flexibility if nonequidistant embedding lags are to be used. 

Note: The sign of `τ` can be both positive and negative, because the sign of `τ` only controls whether a forwards or backwards embedding 
vectors are constructed. 

[^BandtPompe2002]: Bandt, Christoph, and Bernd Pompe. "Permutation entropy: a natural complexity measure for time series." Physical review letters 88.17 (2002): 174102.
"""
function entropy(x::Dataset{N, T}, method::SymbolicPermutation) where {N, T}
    s = zeros(Int, length(x))
    entropy!(s, x, method)
end

function entropy(x::AbstractArray{T, 1}, method::SymbolicPermutation) where T
    τs = Tuple(0:1:(method.m - 1))
    E = genembed(x, τs)
    s = zeros(Int, length(E))
    entropy!(s, E, method)
end

function entropy(x::AbstractArray{T, 1}, τ::Int, method::SymbolicPermutation) where T
    τ != 0 || throw(ArgumentError("Got `τ == 0`. The delay embedding lag must be strictly positive or negative."))
    τs = Tuple(0:τ:τ*(method.m - 1))
    E = genembed(x, τs)
    s = zeros(Int, length(E))
    entropy!(s, E, method)
end

function entropy(x::AbstractArray{T, 1}, emb::GeneralizedEmbedding, method::SymbolicPermutation) where T
    E = genembed(x, emb)
    s = zeros(Int, length(x))
    entropy!(s, x, method)
end

"""
    entropy!(s, x::Dataset, method::SymbolicPermutation)

Compute the permutation entropy of `x`, but using the pre-allocated length-`L` 
symbol array `s`, where `L = length(x)`. This can be used to save some memory 
allocations if the permutation entropy is to be computed for multiple data sets.
"""
function entropy!(s::Vector{Int}, x::Dataset{N, T}, method::SymbolicPermutation) where {N, T}
    length(s) == length(x) || throw(ArgumentError("Need length(h) == length(x), got `length(h)=$(length(h))` and `length(x)==$(length(x))`."))
    for i = 1:length(x)
        s[i] = encode_motif(x[i], N)
    end
    p = _non0hist(s)
    -sum(p .* log.(method.b, p))
end