import DelayEmbeddings.estimate_delay
import DelayEmbeddings.estimate_dimension

export optimal_delay, optimal_dimension, OptimiseDelay, OptimiseDim

"""
    optimal_delay(v; method = "ac_zero"; τs = 1:1:floor(Int, length(v)/10); kwargs...)

Estimate the optimal embedding lag for `v` among the delays `τs`. 
    

# Keyword arguments

- **`method::String = "ac_zero"`**: The delay estimation method. 
    Uses `DynamicalSystems.estimate_delay` under the hood. See its documentation for more info.
- **`τs`**: The lags over which to estimate the embedding lag. Defaults to 10% of the 
    length of the time series.
- **`kwargs::NamedTuple`**: Keyword arguments to the delay estimation methods. Empty by default.
    Keywords `nbins`, `binwidth` are propagated into `DynamicalSystems.mutualinformation`.

# Example 

```julia 
using CausalityToolsBase 

ts = diff(rand(100))
optimal_delay(ts)
optimal_delay(ts, method = "ac_zero")
optimal_delay(ts, method = "ac_zero", τs = 1:10)
```
"""
function optimal_delay(v; method = "ac_zero", τs = 1:1:min(ceil(Int, length(v)/15), 100), kwargs...)
    τ = estimate_delay(v, method, τs; kwargs...)
end

"""
    optimal_dimension(v, τ; dims = 2:8; method = "fnn"; kwargs...)

Estimate the optimal embedding dimension for `v`.

# Arguments

- **`v`**: The data series for which to estimate the embedding dimension.

- **`τ`**: The embedding lag.

- **`dims`**: Dimensions to probe for the optimal dimension.

# Keyword arguments

- **`method`**: Either "fnn" (Kennel's false nearest neighbors method),
    "afnn" (Cao's average false nearest neighbors method) or "f1nn" (Krakovská's
    false first nearest neighbors method). See the source code for
    `DelayEmbeddings.estimate_dimension` for more details.

- **`rtol`**: Tolerance `rtol` in Kennel's algorithms. See [`DelayEmbeddings.fnn`](https://github.com/JuliaDynamics/DelayEmbeddings.jl/blob/master/src/estimate_dimension.jl)
    source code for more details.
    
- **`atol`**: Tolerance `rtol` in Kennel's algorithms. See [`DelayEmbeddings.fnn`](https://github.com/JuliaDynamics/DelayEmbeddings.jl/blob/master/src/estimate_dimension.jl)
    source code for more details.

# Example

```julia 
using CausalityToolsBase 
        
ts = diff(rand(1000))
optimal_dimension(ts)
optimal_dimension(ts, dims = 3:5)
optimal_dimension(ts, method = "afnn")
optimal_dimension(ts, method = "fnn")
optimal_dimension(ts, method = "f1nn")
```
"""
function optimal_dimension(v, τ, method = "f1nn"; dims = 2:8, kwargs...)
    # The embedding dimension should be the dimension returned by
    # estimate_dimension plus one (see DelayEmbeddings.jl source code).
    if method == "fnn"
        γs = estimate_dimension(v, τ, method = "f1nn", dims[1:(end - 1)]; kwargs...)
        # Kennel's false nearest neighbor method should drop to zero near the
        # optimal value of γ, so find the minimal value of γ for the dims
        # we've probed.
        dim = findmin(γs)[2] + 1
        return dim
    elseif method == "afnn"
        γs = estimate_dimension(v, τ, dims[1:(end - 1)], method = "afnn"; kwargs...)
        # Cao's averaged false nearest neighbors method saturates around 1.0
        # near the optimal value of γ, so find the γ closest to 1.0 for the
        # dims we've probed.
        dim = findmin(1.0 .- γs)[2] + 1
        return dim
    elseif method == "f1nn"
        γs = estimate_dimension(v, τ, dims[1:(end - 1)], method = "f1nn"; kwargs...)
        # Krakovská's false first nearest neighbors method drops to zero near
        # the optimal value of γ, so find the minimal value of γ for the dims
        # we've probed.
        dim = findmin(γs)[2] + 1
        return dim
    else
        throw(DomainError("method=$method for estimating dimension is not valid."))
    end
end


"""
    optimal_dimension(v; dims = 2:8,
        method_dimension = "fnn", method_delay = "ac_zero")

Estimate the optimal embedding dimension for `v` by first estimating
the optimal lag, then using that lag to estimate the dimension.

## Arguments
- **`v`**: The data series for which to estimate the embedding dimension.
- **`dims`**: The dimensions to try.
- **`method_delay`**: The method for determining the optimal lag.
"""
function optimal_dimension(v; method = "f1nn",      
        dims = 2:8, 
        method_delay = "ac_zero", 
        τs = 1:1:min(ceil(Int, length(v)/10), min(ceil(Int, length(v)/2), 100))
    )
    τ = optimal_delay(v, method = method_delay, τs = τs)
    optimal_dimension(v, τ, method)
end

abstract type AbstractParameterOptimisation end

""" 
    OptimiseDelay(method_delay = "ac_zero", maxdelay_frac = 0.1; kwargs...) -> OptimiseDelay

Indicates that the delay parameter for an embedding should be optimised using some estimation procedure.

Passing an instance of `OptimiseDelay` to certain functions triggers delay estimation based on the 
length of the time series, which is not necessarily known beforehand. Here, the maximum lag is expressed
as a fraction of the time series length.

## Fields 

- **`method_delay::String = "ac_zero"`**: The delay estimation method. Uses `DynamicalSystems.estimate_delay` 
    under the hood. See its documentation for more info. 
- **`maxdelay_frac::Number = 0.1`**: The maximum number of delays for which to check, expressed as a fraction of 
    the time series length.
- **`kwargs::NamedTuple`**: Arguments to the various methods. Empty by default. Keywords `nbins` and 
    `binwidth` are propagated into `DynamicalSystems.mutualinformation` if `method = mi_min`.

## Example 

```julia
opt_scheme = OptimiseDelay(method_delay = "mi_min", kwargs = (nbins = 10, ))
ts = sin.(diff(diff(rand(5000))))
optimal_delay(ts, opt_scheme)
```
"""
@Base.kwdef struct OptimiseDelay <: AbstractParameterOptimisation
    method_delay::String = "ac_zero"
    maxdelay_frac = 0.1
    kwargs::NamedTuple = NamedTuple()
end

function Base.show(io::IO, x::OptimiseDelay)
    s = "OptimiseDelay(method_delay = $(x.method_delay), maxdelay_frac = $(x.maxdelay_frac))"
    print(io, s)
end

""" 
    OptimiseDim(method_delay::String = "ac_zero", maxdelay_frac::Number = 0.1, 
        method_dim::String = "f1nn", maxdim::Int = 6) -> OptimiseDim

Indicates that the dimension for an embedding should be optimised using some estimation procedure.

To estimate the dimension, the delay lag must also be specified. Therefore, passing an instance of 
`OptimiseDim` to certain functions triggers delay estimation based on the length of the time series, 
which is not necessarily known beforehand. Then, after the delay has been estimated, the dimension
is estimated.

## Fields 

- **`method_dim::String = "f1nn"`**: The dimension estimation method.     
- **`maxdim::Int = 6`**: The maximum dimension to check for. Dimensions `1:maxdim` will be 
    checked.
- **`kwargs_dim::NamedTuple`**: Keyword arguments to the dimension estimation method. Empty by default.
- **`method_delay::String = "ac_zero"`**: The delay estimation method.    
- **`maxdelay_frac::Number = 0.1`**: The maximum number of delays for which to check, expressed as a fraction of 
    the time series length.
- **`kwargs_delay::NamedTuple`**: Keyword arguments to the delay estimation method. Empty by default.
    Keywords `nbins` and `binwidth` are propagated into `DynamicalSystems.mutualinformation` if 
    `method = mi_min`. See also [`optimal_delay`](@ref).

## Example 

```julia 
opt_scheme = OptimiseDim(method_dim = "f1nn", method_delay = "ac_zero")
ts = sin.(diff(diff(rand(5000))))
optimal_dimension(ts, opt_scheme)
```
"""
@Base.kwdef struct OptimiseDim <: AbstractParameterOptimisation
    maxdim::Int = 6
    maxdelay_frac = 0.1
    method_dim::String = "f1nn"
    kwargs_dim::NamedTuple = NamedTuple()
    method_delay::String = "ac_zero"
    kwargs_delay::NamedTuple = NamedTuple()
end

function Base.show(io::IO, x::OptimiseDim)
    s = "OptimiseDim(method_delay = $(x.method_delay), method_dim = $(x.method_dim), maxdim = $(x.maxdim), maxdelay_frac = $(x.maxdelay_frac))"
    print(io, s)
end

import CausalityToolsBase: optimal_delay, optimal_dimension 

"""
    optimal_delay(x, p::OptimiseDelay)

Estimate the optimal delay reconstruction lag for `x` using the 
instructions given by the [`OptimiseDelay`](@ref) instance `p`.

## Example 

```julia 
opt_scheme = OptimiseDelay(method_delay = "ac_zero", kwargs = (nbins = 10, ))
ts = sin.(diff(diff(rand(5000))))
optimal_delay(ts, opt_scheme)
```
"""
function optimal_delay(x, p::OptimiseDelay)
    τs = 1:floor(Int, length(x)*p.maxdelay_frac)
    if length(p.kwargs) > 0
        estimate_delay(x, p.method_delay, τs; p.kwargs...)
    else
        estimate_delay(x, p.method_delay, τs)
    end
end

"""
    optimal_dimension(x, p::OptimiseDim)

Estimate the optimal reconstruction dimension for `x` using the 
instructions given by the [`OptimiseDim`](@ref) instance `p`.

## Example 

```julia 
opt_scheme = OptimiseDim(method_dim = "f1nn", method_delay = "mi_min", kwargs_delay = (nbins = 10, )))
ts = sin.(diff(diff(rand(5000))))
optimal_dimension(ts, opt_scheme)
```
"""
function optimal_dimension(x::AbstractVector{T}, p::OptimiseDim) where T
    τs = 1:floor(Int, length(x)*p.maxdelay_frac)
    if length(p.kwargs_delay) > 0
        τ = estimate_delay(x, p.method_delay, τs; p.kwargs_delay...)
    else
        τ = estimate_delay(x, p.method_delay, τs)
    end
    
    optimal_dimension(x, τ, method = p.method_dim, dims = 1:p.maxdim)
end

