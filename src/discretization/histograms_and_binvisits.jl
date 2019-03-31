export 
joint_visits,
marginal_visits,
non0hist

"""
    joint_visits(points, binning_scheme::RectangularBinning)

Determine which bins are visited by `points` given the rectangular binning
scheme `ϵ`. Bins are referenced relative to the axis minimum.

# Example 

```julia
using DynamicalSystems
pts = Dataset([rand(5) for i = 1:100]);

joint_visits(pts, RectangularBinning(0.2))
```
"""
function joint_visits(points, binning_scheme::RectangularBinning)
    axis_minima, box_edge_lengths = get_minima_and_edgelengths(points, ϵ)
    encode(points, axis_minima, box_edge_lengths)
end

"""
    marginal_visits(points, binning_scheme::RectangularBinning, dims)

Determine which bins are visited by `points` given the rectangular binning
scheme `ϵ`, only along the desired dimensions `dims`. Bins are referenced 
relative to the axis minimum.

# Example 

```julia
using DynamicalSystems
pts = Dataset([rand(5) for i = 1:100]);

# Marginal visits along dimension 3 and 5
marginal_visits(pts, RectangularBinning(0.3), [3, 5])

# Marginal visits along dimension 2 through 5
marginal_visits(pts, RectangularBinning(0.3), 2:5)
```
"""
function marginal_visits(points, binning_scheme::RectangularBinning, dims)
    axis_minima, box_edge_lengths = get_minima_and_edgelengths(points, ϵ)
    dim = length(axis_minima)
    if sort(collect(dims)) == sort(collect(1:dim))
        joint_visits(points, ϵ)
    else
        [encode(pt, axis_minima, box_edge_lengths)[dims] for pt in points]
    end
end

"""
    marginal_visits(joint_visits, dims)

Given a set of precomputed joint visited bins, return the marginal along 
dimensions `dims`.

# Example 

```julia
using DynamicalSystems
pts = Dataset([rand(5) for i = 1:100]);

# First compute joint visits, then marginal visits along dimensions 1 and 4
jv = joint_visits(pts, RectangularBinning(0.2))
marginal_visits(jv, [1, 4])
```
"""
function marginal_visits(joint_visits, dims)
    [bin[dims] for bin in joint_visits]
end

"""
    non0hist(bin_visits)

Return the unordered histogram (vistitation frequency) over the array of `bin_visits`,
which is a vector containing bin encodings (each point encoded by an integer vector).

This method extends `ChaosTools.non0hist`.
"""
function non0hist(bin_visits::Vector{T}) where {T <: Union{Vector, SVector, MVector}}
    L = length(bin_visits)
    hist = Vector{Float64}()

    # Reserve enough space for histogram:
    sizehint!(hist, L)

    sort!(bin_visits, alg = QuickSort)

    # Fill the histogram by counting consecutive equal bins:
    prev_bin = bin_visits[1]
    count = 1
    @inbounds for i in 2:L
        bin = bin_visits[i]
        if bin == prev_bin
            count += 1
        else
            push!(hist, count/L)
            prev_bin = bin
            count = 1
        end
    end
    push!(hist, count/L)

    # Shrink histogram capacity to fit its size:
    sizehint!(hist, length(hist))

    return hist
end

"""
    non0hist(points, binning_scheme::RectangularBinning, dims)

Determine which bins are visited by `points` given the rectangular binning
scheme `ϵ`, considering only the marginal along dimensions `dims`. Bins are referenced 
relative to the axis minimum.

Returns the unordered histogram (vistitation frequency) over the array of bin visits.

This method extends `ChaosTools.non0hist`.
"""
function non0hist(points, binning_scheme::RectangularBinning, dims)
    bin_visits = marginal_visits(points, ϵ, dims)
    L = length(bin_visits)
    hist = Vector{Float64}()

    # Reserve enough space for histogram:
    sizehint!(hist, L)

    sort!(bin_visits, alg = QuickSort)

    # Fill the histogram by counting consecutive equal bins:
    prev_bin = bin_visits[1]
    count = 1
    @inbounds for i in 2:L
        bin = bin_visits[i]
        if bin == prev_bin
            count += 1
        else
            push!(hist, count/L)
            prev_bin = bin
            count = 1
        end
    end
    push!(hist, count/L)

    # Shrink histogram capacity to fit its size:
    sizehint!(hist, length(hist))

    return hist
end