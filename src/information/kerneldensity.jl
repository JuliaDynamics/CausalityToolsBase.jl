import Statistics: std, mean
export 
    Kernel, 
    BoxKernel,
    GaussianKernel,
    silverman_rule

"""
    Kernel

The supertype of all kernels used for kernel density estimaton (KDE).
"""
abstract type Kernel end 

"""
    BoxKernel <: Kernel

Naive box kernel density estimator from [1].
"""
struct BoxKernel <: Kernel end

"""
    GaussianKernel <: Kernel

Gaussian kernel density estimator from [1].
"""
struct GaussianKernel <: Kernel end 

"""
    silverman_rule(pts)

Find the approximately optimal bandwidth for a kernel density estimate, 
assuming the density is Gaussian (Silverman, 1996).
"""
function silverman_rule(pts)
    n_pts = length(pts)
    dim = length(pts[1])

    # Average marginal standard deviation
    σs = zeros(Float64, dim)
    for i = 1:dim
        σs[i] = std([pt[i] for pt in pts])
    end

    # Compute bandwidth from mean standard deviation
    σ = mean(σs)
    
    # Approximately the optimal bandwidth
    σ*(4/(dim + 2))^(1/(dim + 4)) * n_pts^(-(1/(dim + 4)))
end

""" 
    scaling(kernel::Kernel, n::Int, h::Real, [dim::Int])
    scaling(kernel::BoxKernel, n::Int, h::Real)

Return the scaling factor for the given `kernel` if the density 
over `n` pts is to be estimated using bandwidth `h` (for 
datasets of dimension `dim`, if relevant).
"""
function scaling end

#scaling(kernel::GaussianKernel, n:::Int, h::Real, dim) = 1/(h^dim) * (1/(pi^(dim/2)))
scaling(kernel::BoxKernel, n::Int, h::Real) = 1/(2*n*h)

""" 
    evaluate_kernel(kernel::Kernel, args...)

Evaluate the `kernel` with the provided `args`.
"""
function evaluate_kernel end
#    #evaluate_kernel(kernel::Gaussian, d, σ) # distance `d`, mean marginal standard deviation `σ`

"""
    evaluate_kernel(BoxKernel(), idxs_pts_within_range)

Evaluate the the Box kernel by counting the number of points that 
fall within the range of a query point (the points falling inside 
a radius of `h` has been precomputed).
"""
function evaluate_kernel(kerneltype::BoxKernel, idxs_pts_within_range) 
    # The point itself is always included, so subtract 1
    length(idxs_pts_within_range) - 1
end