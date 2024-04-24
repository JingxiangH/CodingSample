#==========================
        Packages
==========================#

import Pkg
Pkg.activate(pwd())

try
    using Random, Parameters, Interpolations
catch e
    Pkg.add(["Random","Parameters","Interpolations"])
    using Random, Parameters, Interpolations
end

include("Tauchen.jl")

#============================
        Model Settings
============================#

@consts begin
    γ = 2
    β = 0.98
    μ = 1
    bb = 0.4
    ρ = 0.9
    σ² = 0.05
    σ = σ² ^ (1/2)
    p = 0.05
    q = 0.25
    r = 0.01
end

lnY(lnYₜ₋₁,εₜ) = (1 - ρ) * log(μ) + ρ * lnYₜ₋₁ + εₜ

U(C) = C^(1 - γ) / (1 - γ)

# This period's starting wealth
f(lnYₜ, Aₜ) = exp(lnYₜ) + Aₜ
# Savings this period based on next periods' assets
savings(Aₜ₊₁) = Aₜ₊₁/(1+r)

# Budget Constraint defines Cₜ(Yₜ, Aₜ, Aₜ₊₁) = income - savings
c(lnYₜ, Aₜ, Aₜ₊₁) = f(lnYₜ, Aₜ) - savings(Aₜ₊₁)

# Maximum A' could be for C>0, given Y and A
# The upper bound is calculated by each case, this is a more 
Aprime(lnYₜ, Aₜ, Cₜ) = (1+r) * (exp(lnYₜ) + Aₜ - Cₜ)
max_Ap(lnYₜ, Aₜ) = Aprime(lnYₜ, Aₜ, 0)


"""Labor Income: Y: employed income; X: 1 if employed, 0 o.w.; bb = unemployed income"""
Yfun(Y, X) = X ? Y : bb
# X is defined as a dummy variable, and the function returns the income


#============================
        Preparations
============================#
NY = 7
NstdY = 4
GridlnY, GridPY = tauchen(NY, log(μ), ρ, σ, NstdY)
GridY = ℯ.^GridlnY

GridPY = GridPY'

GridA_upper = 200
GridA_lower = 0
NA = 1_000
GridA = range(GridA_lower, GridA_upper, length=NA)

AY = [(a, y) for y ∈ GridlnY for a ∈ GridA]
AA = [a for (a, y) ∈ AY]
YY = [y for (a, y) ∈ AY]

#============================
        Bellman
============================#

"""Return interpolated values of EV at Aₜ₊₁ points given input EV vector on regular grid"""
function interpolate_EV(EV::AbstractArray, lnYₜ::AbstractArray, Aₜ₊₁::AbstractArray)
    # Convert EV to matrix for interpolation
    EVmat = reshape(EV, NA, NY)
    # Create interpolation function (based on regular grids 1:NA and 1:NY)
    Interp = interpolate(EVmat, BSpline(Cubic(Line(OnGrid()))))
    # Scale the inputs to match the actual grids
    sInterp = Interpolations.scale(Interp, GridA, GridlnY)
    # Interpolate on vectors of Aₜ₊₁ and lnYₜ
    EVinterp = sInterp.(Aₜ₊₁, lnYₜ)
    # The output will be multiplied by the markov transition matrix for Y later to EV(Aₜ₊₁, lnYₜ) → EV(Aₜ₊₁, lnYₜ₊₁)
    return EVinterp
end
function interpolate_EV(EV::AbstractArray, lnYₜ::Real, Aₜ₊₁::Real)
    # Convert EV to matrix for interpolation
    EVmat = reshape(EV, NA, NY)
    # Create interpolation function (based on regular grids 1:NA and 1:NY)
    Interp = interpolate(EVmat, BSpline(Cubic(Line(OnGrid()))))
    # Scale the inputs to match the actual grids
    sInterp = Interpolations.scale(Interp, GridA, GridlnY)
    # Interpolate on scalar Aₜ₊₁ and lnYₜ
    EVinterp = sInterp(Aₜ₊₁, lnYₜ)
    # The output will be multiplied by the markov transition matrix for Y later to EV(Aₜ₊₁, lnYₜ) → EV(Aₜ₊₁, lnYₜ₊₁)
    return EVinterp
end
function interpolate_EV(EV::AbstractArray)
    # Convert EV to matrix for interpolation
    EVmat = reshape(EV, NA, NY)
    # Create interpolation function (based on regular grids 1:NA and 1:NY)
    Interp = interpolate(EVmat, BSpline(Cubic(Line(OnGrid()))))
    # Scale the inputs to match the actual grids
    sInterp = Interpolations.scale(Interp, GridA, GridlnY)
    # Return interpolated function on scalar Aₜ₊₁ and lnYₜ
    EVinterp(Aₜ₊₁, lnYₜ) = sInterp(Aₜ₊₁, lnYₜ)
    return EVinterp
end