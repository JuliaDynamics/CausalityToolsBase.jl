x = rand(100)

@test optimal_delay(x; τs = 1:10) isa Int
@test optimal_delay(x, method_delay = "ac_zero") isa Int
@test optimal_dimension(x, 2, method_dim = "f1nn", method_delay = "mi_min") isa Int
@test optimal_dimension(x, method_delay = "mi_min") isa Int

opt_scheme = OptimiseDelay(method_delay = "mi_min", kwargs = (nbins = 10, ))
opt_scheme = OptimiseDelay(method_delay = "ac_zero")

ts = sin.(diff(diff(rand(5000))))
@test optimal_delay(ts, opt_scheme) isa Int

opt_scheme = OptimiseDim(method_dim = "f1nn", method_delay = "mi_min", kwargs_delay = (nbins = 10, ))
ts = sin.(diff(diff(rand(5000))))
@test optimal_dimension(ts, opt_scheme) isa Int

opt_scheme = OptimiseDim(method_dim = "f1nn", method_delay = "ac_zero")
@test optimal_dimension(ts, opt_scheme) isa Int