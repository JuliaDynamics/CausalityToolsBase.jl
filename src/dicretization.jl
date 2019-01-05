
""" 
    BinningScheme

The supertype of all binning schemes in the CausalityTools ecosystem. 

"""
abstract type BinningScheme end


"""
    TriangulationBinningScheme
    
A binning scheme for a triangulated simplex partition.
"""
struct TriangulationBinning <: BinningScheme end

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
struct RefinedTriangulationBinningMaxRadius <: BinningScheme
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
struct RefinedTriangulationBinningSplitFactor <: BinningScheme
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
struct RefinedTriangulationBinningSplitQuantile <: BinningScheme
    split_quantile::Float64
    simplex_split_factor::Int
end

"""
    RectangularBinningScheme
    
Instructions for creating a rectangular box partition.

## Fields 

- **`ϵ::Union{Int, Float64, Vector{Int}, Vector{Float64}}`**: The instructions for deciding 
    the edge lengths of the rectangular boxes. The following `ϵ` are valid:
        1. `ϵ::Int` divides each axis into `ϵ` intervals of the same size.
        2. `ϵ::Float` divides each axis into intervals of size `ϵ`.
        3. `ϵ::Vector{Int}` divides the i-th axis into `ϵᵢ` intervals of the same size.
        4. `ϵ::Vector{Float64}` divides the i-th axis into intervals of size `ϵᵢ`.
"""
struct RectangularBinning <: BinningScheme
    ϵ::Union{Int, Float64, Vector{Int}, Vector{Float64}}
end



export 
BinningScheme,
TriangulationBinning,
RefinedTriangulationBinningMaxRadius,
RefinedTriangulationBinningSplitFactor,
RefinedTriangulationBinningSplitQuantile,
RectangularBinning