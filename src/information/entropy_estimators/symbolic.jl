export 
    SymbolicEntropyEstimator,
    PermutationEntropyEstimator,
    SymbolicPermutation,
    encode_motif, 
    symbolize, symbolize!

"""
    SymbolicEntropyEstimator <: EntropyEstimator

The supertype of all symbolic entropy estimators.
"""
abstract type SymbolicEntropyEstimator <: EntropyEstimator end

"""
    PermutationEntropyEstimator <: EntropyEstimator

The supertype of all permutation-based symbolic entropy estimators.
"""
abstract type PermutationEntropyEstimator <: SymbolicEntropyEstimator end

"""
    SymbolicPermutation(; b::Real = 2, m::Int = 2)

A symbolic permutation entropy estimator using motifs of length `m`.
The entropy is computed to base `b` (the default `b = 2` gives the 
entropy in bits).

The motif length must be ≥ 2. By default `m = 2`, which is the shortest 
possible permutation length which retains any meaningful dynamical information.
"""
struct SymbolicPermutation <: PermutationEntropyEstimator
    b::Real
    m::Int 
    
    function SymbolicPermutation(; b::Real = 2, m::Int = 2)
        m >= 2 || throw(ArgumentError("Dimensions of individual marginals must be at least 2. Otherwise, symbol sequences cannot be assigned to the marginals. Got m=$(m)."))

        new(b, m)
    end
end

""" 
    encode_motif(x, m::Int = length(x))

Encode the length-`m` motif `x` (a vector of indices that would sort some vector `v` in ascending order) 
into its unique integer symbol according to Algorithm 1 in Berger et al. (2019)[^Berger2019].

Note: no error checking is done to see if `length(x) == m`, so be sure to provide the correct motif length!
## Example 

```julia
# Some random vector
v = rand(5)

# The indices that would sort `v` in ascending order. This is now a permutation 
# of the index permutation (1, 2, ..., 5)
x = sortperm(v)

# Encode this permutation as an integer.
encode_motif(x)
```
[^Berger2019]: Berger, Sebastian, et al. "Teaching Ordinal Patterns to a Computer: Efficient Encoding Algorithms Based on the Lehmer Code." Entropy 21.10 (2019): 1023.
"""
function encode_motif(x, m::Int = length(x))
    n = 0
    for i = 1:m-1
        for j = i+1:m
            n += x[i] > x[j] ? 1 : 0
        end
        n = (m-i)*n
    end
    
    return n
end


""" 
    symbolize(x::Dataset{N, T}, method::SymbolicPermutation) where {N, T} → Vector{Int}

Symbolize the vectors in `x` using Algorithm 1 from Berger et al. (2019)[^Berger2019].

The symbol length is automatically determined from the dimension of the input data 
(hence, ignoring `method.m`).

## Example 

```julia
D = Dataset([rand(7) for i = 1:1000])
symbolize(D, SymbolicPermutation())
````
[^Berger2019]: Berger, Sebastian, et al. "Teaching Ordinal Patterns to a Computer: Efficient Encoding Algorithms Based on the Lehmer Code." Entropy 21.10 (2019): 1023.
"""
function symbolize(x::Dataset{D, T}, method::PermutationEntropyEstimator) where {D, T}
    s = zeros(Int, length(x))
    symbolize!(s, x, method)
    return s
end

function fill_symbolvector!(s, x, sp, N::Int)
    @inbounds for i = 1:length(x)
        sortperm!(sp, x[i])
        s[i] = encode_motif(sp, N)
    end
end

""" 
    symbolize!(s::T, x::Dataset, method::SymbolicPermutation) where T <: AbstractVector{Int} → T

Symbolize the vectors in `x`, storing the symbols in the pre-allocated length-`L` integer container `s`,
where `L = length(x)`.
"""
function symbolize!(s::AbstractVector{Int}, x::Dataset{N, T}, method::SymbolicPermutation) where {N, T}
    #= 
    Loop over embedding vectors `E[i]`, find the indices `p_i` that sort each `E[i]`,
    then get the corresponding integers `k_i` that generated the 
    permutations `p_i`. Those integers are the symbols for the embedding vectors
    `E[i]`.
    =#
    sp = zeros(Int, N) # pre-allocate a single symbol vector that can be overwritten.
    fill_symbolvector!(s, x, sp, N)
    
    return s
end
