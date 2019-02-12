pts = [rand(5) for i = 1:1000];
spts = [SVector{5, Float64}(pt) for pt in pts]
mpts = [MVector{5, Float64}(pt) for pt in pts]
D = Dataset(pts);

ϵs = [5, 0.5, [0.3 for i = 1:5], [10 for i = 1:5]]

refpoint = [0, 0, 0]
steps = [0.2, 0.2, 0.3]
@test encode(rand(3), refpoint, steps) isa Vector{Int}
@test encode(SVector{3, Float64}(rand(3)), refpoint, steps) isa Vector{Int}
@test encode(MVector{3, Float64}(rand(3)), refpoint, steps) isa Vector{Int}

# Infer that we want a rectangular binning.
for ϵ in ϵs
    @test get_minima(pts, ϵ) isa Vector{Float64}
    @test get_minima(D, ϵ) isa Vector{Float64}
    @test get_minima(spts, ϵ) isa Vector{Float64}
    @test get_minima(mpts, ϵ) isa Vector{Float64}

    @test get_edgelengths(pts, ϵ) isa Vector{Float64}
    @test get_edgelengths(D, ϵ) isa Vector{Float64}
    @test get_edgelengths(spts, ϵ) isa Vector{Float64}
    @test get_edgelengths(mpts, ϵ) isa Vector{Float64}

    @test get_minima_and_edgelengths(pts, ϵ) isa Tuple{Vector{Float64}, Vector{Float64}}
    @test get_minima_and_edgelengths(D, ϵ) isa Tuple{Vector{Float64}, Vector{Float64}}
    @test get_minima_and_edgelengths(spts, ϵ) isa Tuple{Vector{Float64}, Vector{Float64}}
    @test get_minima_and_edgelengths(mpts, ϵ) isa Tuple{Vector{Float64}, Vector{Float64}}
end

# Being explicit that we want a rectangular binning
for ϵ in ϵs
    ϵ = RectangularBinning(ϵ)
    
    @test get_minima(pts, ϵ) isa Vector{Float64}
    @test get_minima(D, ϵ) isa Vector{Float64}
    @test get_minima(spts, ϵ) isa Vector{Float64}
    @test get_minima(mpts, ϵ) isa Vector{Float64}

    @test get_edgelengths(pts, ϵ) isa Vector{Float64}
    @test get_edgelengths(D, ϵ) isa Vector{Float64}
    @test get_edgelengths(spts, ϵ) isa Vector{Float64}
    @test get_edgelengths(mpts, ϵ) isa Vector{Float64}

    @test get_minima_and_edgelengths(pts, ϵ) isa Tuple{Vector{Float64}, Vector{Float64}}
    @test get_minima_and_edgelengths(D, ϵ) isa Tuple{Vector{Float64}, Vector{Float64}}
    @test get_minima_and_edgelengths(spts, ϵ) isa Tuple{Vector{Float64}, Vector{Float64}}
    @test get_minima_and_edgelengths(mpts, ϵ) isa Tuple{Vector{Float64}, Vector{Float64}}
end