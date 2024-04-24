import Pkg
Pkg.activate(pwd())

try
    using Random
catch e
    Pkg.add(["Random"])
    using Random
end

include("Tauchen.jl")

