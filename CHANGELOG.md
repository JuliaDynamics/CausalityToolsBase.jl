# Release v0.2.0

A lightweight package providing functionality used throughout the `CausalityTools` ecosystem. 

# New functionality

## New functionality
- **Rectangular binnings**. 
    1. Bin-encode data points relative to some reference point, assuming a rectangular grid. Use `encode` for this.
    2. Determine joint and marginal bin visits given a set of points and a rectangular grid specification. Use `marginal_visits` and `joint_visits` for this.
    3. Compute the unordered histogram (visitation frequency) given a set of points and a rectangular grid specification. Extends `ChaosTools.non0hist` for custom rectangular grids (only cubes are allowed in `ChaosTools`). Can be used with the same  syntax as `marginal_visits`, 
    so that `non0hist(points, ϵ, dims)` will give the histogram over the visited bins of the rectangular grid specified by `ϵ`, considering the marginal
    along the given dimensions (`dims`).  

## Improvements
- Improved documentation for existing methods.

# Release v0.1.0

A lightweight package providing functionality used throughout the `CausalityTools` ecosystem. 

# New functionality
- Wrappers for embedding dimension and lags from `DelayEmbeddings`.
- Abstract partition types. 
- Abstract simplex intersection types. 