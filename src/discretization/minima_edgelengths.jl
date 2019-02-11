export 
get_minima_and_edgelengths, 
get_edgelengths, 
get_minima

"""
    get_minima_and_edgelengths(points, ϵ) -> (Vector{Float}, Vector{Float})

Find the minima along each axis of the embedding, and computes appropriate
`stepsizes` given `ϵ`, which provide instructions on how to grid the space.
Assumes each point is a column vector.

Specifically, the binning procedure is controlled by the type of `ϵ`:

1. `ϵ::Int` divides each axis into `ϵ` intervals of the same size.
2. `ϵ::Float` divides each axis into intervals of size `ϵ`.
3. `ϵ::Vector{Int}` divides the i-th axis into `ϵᵢ` intervals of the same size.
4. `ϵ::Vector{Float64}` divides the i-th axis into intervals of size `ϵᵢ`.
"""
function get_minima_and_edgelengths(points, ϵ)
    # The dimension is automatically inferred for static vectors; for regular 
    # vectors, we need to determine it by the vector size.
    #if points isa Vector{Vector}
    #    D = length(points[1])
    #end
    #::Union{Dataset{dim, T}, Vector{SVector{dim, T}}, Vector{Vector{T}}}
    D = length(points[1])
    n_pts = length(points)

    axisminima = minimum.([minimum.([pt[i] for pt in points]) for i = 1:D])
    top = maximum.([maximum.([pt[i] for pt in points]) for i = 1:D])
    top .= top .+ (top .- axisminima) ./ 100

    edgelengths = Vector{Float64}(undef, D)
    if ϵ isa Float64
        edgelengths = [ϵ for i in 1:D]
    elseif ϵ isa Vector{Float64}
        edgelengths .= ϵ
    elseif ϵ isa Int
        edgelengths = (top - axisminima) / ϵ
    elseif ϵ isa Vector{Int}
        edgelengths = (top - axisminima) ./ ϵ
    elseif ϵ isa Tuple{Vector{Tuple{Float64, Float64}}, Int}
        # We have predefined axis minima and axis maxima.
        n_bins = ϵ[2]
        stepsizes = zeros(Float64, dim)
        edgelengths = zeros(Float64, dim)

        for i = 1:dim 
            edgelengths[i] = (maximum(ϵ[1][i]) - minimum(ϵ[1][i]))/n_bins
            axisminima[i] = minimum(ϵ[1][i])
        end
    end

    axisminima, edgelengths
end

get_minima(points, ϵ) = get_minima_and_edgelengths(points, ϵ)[1]
get_edgelengths(points, ϵ) = get_minima_and_edgelengths(points, ϵ)[2]

get_minima_and_edgelengths(points, ϵ::RectangularBinning) = get_minima_and_edgelengths(points, ϵ.ϵ)
get_minima(points, ϵ::RectangularBinning) = get_minima(points, ϵ.ϵ)
get_edgelengths(points, ϵ::RectangularBinning) = get_minima(points, ϵ.ϵ)
