export EntropyEstimator

"""
    EntropyEstimator 

The supertype of all entropy estimators. These estimators all have in common 
that they directly or indirectly estimate entropies over some generalized 
delay reconstruction.
"""
abstract type EntropyEstimator end
