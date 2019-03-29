
export 
BinningScheme,
TriangulationBinningScheme,
TriangulationBinning,
RefinedTriangulationBinningMaxRadius,
RefinedTriangulationBinningSplitFactor,
RefinedTriangulationBinningSplitQuantile,
RectangularBinning

""" 
    BinningScheme

The supertype of all binning schemes in the CausalityTools ecosystem. 
"""
abstract type BinningScheme end

""" 
    TriangulationBinningScheme

The supertype of all triangulation binning schemes in the CausalityTools ecosystem.
""" 
abstract type TriangulationBinningScheme end

""" 
    RectangularBinningScheme

The supertype of all rectangular binning schemes in the CausalityTools ecosystem.
""" 
abstract type RectangularBinningScheme end



"""
    TriangulationBinningScheme
    
A binning scheme for a triangulated simplex partition.
"""
struct TriangulationBinning <: TriangulationBinningScheme end

"""
    RefinedTriangulationBinningMaxRadius
    
A binning scheme for a triangulated simplex partition where some simplices have been 
refined (subdivided by a shape-preserving simplex subdivision algorithm).

The maximum radius bound is applied by first doing an initial triangulation, the 
splitting simplices whose radius is large until all simplices have radii less than 
the resulting radius bound.

## Fields 
- **`max_radius_frac::Float64`**: The maximum radius expressed as a fraction of the 
radius of the largest simplex of the initial triangulation.
"""
struct RefinedTriangulationBinningMaxRadius <: TriangulationBinningScheme
    max_radius_frac::Float64
end

"""
    RefinedTriangulationBinningSplitFactor
    
A binning scheme for a triangulated simplex partition where some simplices have been 
refined (subdivided by a shape-preserving simplex subdivision algorithm).

The split factor bound controls how many times each simplex of the initial triangulation 
is to be split.

## Fields 
- **`simplex_split_factor::Int`**: The number of times each simplex is split.
"""
struct RefinedTriangulationBinningSplitFactor <: TriangulationBinningScheme
    simplex_split_factor::Int
end

"""
    RefinedTriangulationBinningSplitQuantile
    
A binning scheme for a triangulated simplex partition where some simplices have been 
refined (subdivided by a shape-preserving simplex subdivision algorithm).

The split fraction bound controls how many times each simplex of the initial triangulation 
is to be split.

## Fields 
- **`split_quantile::Float64`**: All simplices with radius larger than the 
    `split_quantile`-th quantile of the radii of the simplices in initial triangulation 
    are split with a splitting factor of `simplex_split_factor`.
- **`simplex_split_factor::Int`**: The number of times each simplex is split.
"""
struct RefinedTriangulationBinningSplitQuantile <: TriangulationBinningScheme
    split_quantile::Float64
    simplex_split_factor::Int
end

"""
    RectangularBinning(ϵ)
    
Instructions for creating a rectangular box partition using the binning scheme `ϵ`. 
The following `ϵ` are valid:

## Data ranges along each axis dictated by data ranges 

1. `RectangularBinning(ϵ::Int)` divides each axis into `ϵ` equal-length intervals.

2. `RectangularBinning(ϵ::Float64)` divides each axis into intervals of fixed size `ϵ`.

3. `RectangularBinning(ϵ::Vector{Int})` divides the i-th axis into `ϵᵢ` equal-length 
    intervals.

4. `RectangularBinning(ϵ::Vector{Float64})` divides the i-th axis into intervals of size 
    `ϵ[i]`.

## Custom ranges along each axis


5. `RectangularBinning(ϵ::Tuple{Vector{Tuple{Float64,Float64}},Int64})` creates intervals 
    along each axis from ranges indicated by a vector of `(min, max)` tuples , then divides 
    each axis into the same integer number of equal-length intervals. 
    
It's probably easier to use the following constructors

- `RectangularBinning(minmaxes::Vector{Tuple{Vararg{T, N}}}, n_intervals::Int)` takes a 
    vector of tuples indiciating the (min, max) along each axis and `n_intervals` that 
    indicates how many equal-length intervals those ranges should be split into. 
    
- `RectangularBinning(minmaxes::Vector{<:AbstractRange{T}}, n_intervals::Int)` does the 
    same, but the arguments are provided as ranges.
"""
struct RectangularBinning <: RectangularBinningScheme
    ϵ::Union{Int, Float64, Vector{Int}, Vector{Float64}, Tuple{Vector{Tuple{Float64,Float64}},Int64}}
end


RectangularBinning(minmaxes::Vector{Tuple{Vararg{T, N}}}, n_intervals::Int) where {T, N} = 
    RectangularBinning(([float.(x) for x in minmaxes], n_intervals))


function RectangularBinning(minmaxes::Vector{<:AbstractRange{T}}, n_intervals::Int) where T
    v = [(minimum(x), maximum(x)) for x in minmaxes]
    RectangularBinning(v, n_intervals)
end


function RectangularBinning(n_intervals::Int, 
        minmaxes::Vararg{<:AbstractRange{T}, N}) where {T, N}
    v = [(minimum(x), maximum(x)) for x in minmaxes]
    RectangularBinning(v, n_intervals)
end