
"""
    _non0hist(x::Vector{T})

Compute the normalized histogram for `x`, ignoring zero-bins. 

This is a version of `ChaosTools.non0hist`.
"""
function _non0hist(x::Vector{T}) where T <: Real
    L = length(x)

    hist = Vector{Float64}()
    # Reserve enough space for histogram:
    sizehint!(hist, L)

    sx = sort(x, alg = QuickSort)

    # Fill the histogram by counting consecutive equal values:
    prev_val, count = sx[1], 0
    for val in sx
        if val == prev_val
            count += 1
        else
            push!(hist, count/L)
            prev_val = val
            count = 1
        end
    end
    push!(hist, count/L)

    # Shrink histogram capacity to fit its size:
    sizehint!(hist, length(hist))
    return hist
end

function combine_marginals(x, y)
    L = length(x)
    x = Dataset(x)
    y = Dataset(y)

    N1, N2 = length(x[1]), length(y[1])
    D = N1 + N2
    T = eltype(x)

    xys = Vector{SVector{2, T}}(undef, L)
    tmp = zeros(D)
    @inbounds for i = 1:L
        for j = 1:N1 
            tmp[j] = x[i][j]
        end
        for j = 1:N2 
            tmp[j+N1] = x[i][j]
        end
        xys[i] = SVector{D, T}(tmp)
    end
    xy = Dataset(xys)
end


function combine_marginals(x::Dataset{N1, T}, y::Dataset{N2, T}) where {N1, N2, T}
    L = length(x)
    D = N1 + N2
    xys = Vector{SVector{D, T}}(undef, L)
    tmp = zeros(D)

    @inbounds for i = 1:L
        for j = 1:N1 
            tmp[j] = x[i][j]
        end
        for j = 1:N2 
            tmp[j+N1] = x[i][j]
        end
        xys[i] = SVector{D, T}(tmp)
    end
    xy = Dataset(xys)
end
