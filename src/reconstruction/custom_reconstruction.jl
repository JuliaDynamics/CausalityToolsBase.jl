export 
Lags,
Positions,
customembed,
CustomReconstruction


abstract type ReconstructionParameters end

"""
    Lags

Wrapper type for lags used when performing custom state space reconstructions.
Used in combination with `Positions` to specify how a `CustomReconstruction`
should be constructed.

## Examples
- `Lags(2, 0, -3, 1)` indicates a 4-dimensional state space reconstruction where 
    the first variable has a positive lag of 2, 
    the second variable is not lagged, 
    the third variable has a lag of -3, 
    and the fourth variable has a positive lag of 1. 
- `Lags(0, 0)` indicates a 2-dimensional state space reconstruction where both 
    variables are not lagged.
"""
struct Lags <: ReconstructionParameters
    lags
    function Lags(args...)
        lags = vcat(args...)
        
        new(lags)
    end
end

Base.getindex(l::Lags, i) = getindex(l.lags, i)
Base.length(l::Lags) = length(l.lags)
Base.iterate(l::Lags) = iterate(l.lags)
Base.iterate(l::Lags, state) = iterate(l.lags, state)

"""
    Positions

Wrapper type for the positions the different dynamical variables appear in when 
constructing a custom state space reconstruction. Used in combination with
`Lags` to specify how a `CustomReconstruction` should be constructed. Each 
of the positions must refer to a dynamical variable (column) actually present in the 
dataset.

## Examples
- `Positions(1, 2, 1, 5)` indicates a 4-dimensional state space reconstruction where 
    1. the 1st coordinate axis of the reconstruction should be formed from the 
    first variable/column of the input data.
    2. the 2nd coordinate axis of the reconstruction should be formed from the 
    2nd variable/column of the input data.
    3. the 3rd coordinate axis of the reconstruction should be formed from the 
    1st variable/column of the input data.
    4. the 4th coordinate axis of the reconstruction should be formed from the 
    5th variable/column of the input data.

- `Positions(-1, 2)` indicates a 2-dimensional reconstruction, but will not work, because 
    each position must refer to the index of a dynamical variable (column) of a dataset 
    (indexed from 1 and up).
"""
struct Positions <: ReconstructionParameters
    positions
    
    function Positions(args...)
        pos = vcat(args...)
        if !all(pos .> 0)
            throw(ArgumentError("Positions must refer to the index of dynamical variables present in the dataset (cannot be zero or negative)"))
        end
        
        new(pos)
    end
end
Base.getindex(l::Positions, i) = getindex(l.positions, i)
Base.length(l::Positions) = length(l.positions)
Base.iterate(l::Positions) = iterate(l.positions)
Base.iterate(l::Positions, state) = iterate(l.positions, state)


struct CustomReconstruction{dim, T}
    reconstructed_pts::Dataset{dim, T}
    
    CustomReconstruction(d::Dataset{dim, T}) where {dim, T} = new{dim, T}(d) 
    
    function CustomReconstruction(pts::Vector{VT}) where VT
        CustomReconstruction(Dataset(pts))
    end
            
    function CustomReconstruction(pts::AbstractArray{T, 2}) where T
        if size(pts, 1) > size(pts, 2)
            CustomReconstruction(Dataset(pts))
        else
            CustomReconstruction(Dataset(transpose(pts)))
        end
    end
end

function CustomReconstruction(pts::Vector{VT}, positions::Positions, lags::Lags) where {VT}
    dim = length(pts[1])
    T = eltype(pts[1])
    if any(positions .> dim)
        outside_pos = positions[findall(positions .> dim)]
        ndims = length(pts[1])
        throw(ArgumentError("Position(s) $outside_pos refer to variables not present in the dataset, which has only $ndims variables"))
    end
    
    customembed(pts, positions, lags)        
end
    
function CustomReconstruction(pts::AbstractArray{T, 2}, positions::Positions, lags::Lags) where {T}
    if size(pts, 1) > size(pts, 2)
        D = customembed(pts, positions, lags)
    else
        D = customembed(transpose(pts), positions, lags)
    end 
end
        
function CustomReconstruction(pts::Dataset{dim, T}, positions::Positions, lags::Lags) where {dim, T}
    customembed(pts, positions, lags)
end

function Base.show(io::IO, cr::CustomReconstruction{dim, T} where {dim, T}) 
    println(string(typeof(cr)))
    show(cr.reconstructed_pts)
end

Base.length(r::CustomReconstruction) = length(r.reconstructed_pts)
Base.size(r::CustomReconstruction) = size(r.reconstructed_pts)
Base.getindex(r::CustomReconstruction, i) = getindex(r.reconstructed_pts, i)
Base.getindex(r::CustomReconstruction, i, j) = getindex(r.reconstructed_pts, i, j)
Base.firstindex(r::CustomReconstruction) = firstindex(r.reconstructed_pts)
Base.lastindex(r::CustomReconstruction) = lastindex(r.reconstructed_pts)
Base.iterate(r::CustomReconstruction) = iterate(r.reconstructed_pts)
Base.iterate(r::CustomReconstruction, state) = iterate(r.reconstructed_pts, state)
Base.eltype(r::CustomReconstruction) = eltype(r.reconstructed_pts, state)
Base.IndexStyle(r::CustomReconstruction) = IndexStyle(r.reconstructed_pts)



function fill_embedding_pts!(embeddingpts, pts, start_idxs, positions)
    npts = length(embeddingpts)
    edim = length(positions)
    
    @inbounds for j = 1:edim
        for i = 1:npts
            embeddingpts[i][j] = pts[start_idxs[j] + i][positions[j]]
        end
    end
end

"""
    customembed(pts, positions::Positions, lags::Lags)

Creates a custom embedding from a set of points (`pts`), 
where the i-th embedding column/variable is constructed by
lagging the `positions[i]`-th variable/column of `pts` by 
a lag of `lags[i]`. 

*Note: `pts[k]` must refer to the `k`th point of the dataset,
not the `k`th dynamical variable/column.*
"""
function customembed(pts, positions::Positions, lags::Lags)
    positions, lags = positions.positions, lags.lags
    
    # Dimension of the original space 
    dim = length(pts[1])
    
    # Dimension of the embedding space
    @assert length(positions) == length(lags)
    edim = length(lags)

    minlag, maxlag = minimum(lags), maximum(lags)
    npts = length(pts) - (maxlag + abs(minlag))
    Tpts = eltype(pts[1])
    embeddingpts = [zeros(Tpts, edim) for i = 1:npts]
    start_idxs = zeros(Int, edim)
    
    # Determine starting indices for each axis.
    for i = 1:edim
        lag = lags[i]
        pos = positions[i]
        if lag > 0
            start_idxs[i] = (abs(minlag)) + lag
        elseif lag < 0
            start_idxs[i] = (abs(minlag)) - abs(lag)
        elseif lag == 0
            start_idxs[i] = abs(minlag)
        end
    end
            
    fill_embedding_pts!(embeddingpts, pts, start_idxs, positions)     
    
    return CustomReconstruction(Dataset(embeddingpts))
end

"""
    customembed(pts)

Wrap the set of points (`pts`) in a `CustomReconstruction` instance, 
not lagging any of the variables.
        
*Note: `pts[k]` must refer to the `k`th point of the dataset,
not the `k`th dynamical variable/column.*
"""
function customembed(pts)
    CustomReconstruction(pts)
end