#==========================
        Packages
==========================#

import Pkg

try
    using Random, Parameters, Interpolations, Optim, Plots
    using Optim: maximize, maximizer
catch e
    Pkg.add(["Random","Parameters","Interpolations","Optim","Plots"])
    using Random, Parameters, Interpolations, Optim, Plots
    using Optim: maximizer, maximum
end

pyplot()

include("Tauchen.jl")

if Sys.iswindows()
    cd("")
else
    cd("/Users/huangjingxiang/Library/CloudStorage/Dropbox/大三下/Coding Sample/Julia Solving Consumption-Savings with Uncertainty")
end

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


"""Vector Bellman function when Employed this period"""
function BellmanE(EVe::AbstractArray, EVu::AbstractArray, Aₜ::AbstractArray, lnYₜ::AbstractArray, Aₜ₊₁::AbstractArray)
    # EMPLOYED: vector A', lnY, EVe, EVu
    C = c.(lnYₜ, Aₜ, Aₜ₊₁)
    # Interpolate EVe and EVu at Aₜ₊₁, lnYₜ
    EVe2 = interpolate_EV(EVe, lnYₜ, Aₜ₊₁)
    EVu2 = interpolate_EV(EVu, lnYₜ, Aₜ₊₁)
    # P(emp | emp) = 1-p; P(unemp | emp) = P
    Ve = U.(C) .+ β*( (1-p)*EVe2 + p*EVu2 )
    return Ve
end

"""Scalar Bellman function when Employed this period.
    EVe, EVu are interpolation functions of (Aₜ₊₁, lnYₜ)
"""
function BellmanE(EVe::Function, EVu::Function, Aₜ::Real, lnYₜ::Real, Aₜ₊₁::Real)
    # EMPLOYED: vector A', lnY, EVe, EVu
    C = c(lnYₜ, Aₜ, Aₜ₊₁)
    # P(emp | emp) = 1-p; P(unemp | emp) = P
    Ve = U(C) + β*( (1-p)*EVe(Aₜ₊₁, lnYₜ) + p*EVu(Aₜ₊₁, lnYₜ) )
    return Ve
end


"""Vector Bellman function when Unemployed this period"""
function BellmanU(EVe::AbstractArray, EVu::AbstractArray, Aₜ::AbstractArray, Aₜ₊₁::AbstractArray)
    # UNEMPLOYED: vector A', lnY=bb, EVe, EVu
    C = c.(log(bb), Aₜ, Aₜ₊₁)
    # Interpolate EVe and EVu at Aₜ₊₁, lnYₜ
    lnYₜ = repeat([log(bb)], length(Aₜ))
    EVe2 = interpolate_EV(EVe, lnYₜ, Aₜ₊₁)
    EVu2 = interpolate_EV(EVu, lnYₜ, Aₜ₊₁)
    # P(emp | unemp) = q; P(unemp | unemp) = 1-q
    Vu = U.(C) .+ β*( q*EVe2 .+ (1-q)*EVu2 )
    return Vu
end

"""Scalar Bellman function when Unemployed this period.
    EVe, EVu are interpolation functions of (Aₜ₊₁, lnYₜ)
"""
function BellmanU(EVe::Function, EVu::Function, Aₜ::Real, Aₜ₊₁::Real)
    # UNEMPLOYED: vector A', lnY=bb, EVe, EVu
    C = c(log(bb), Aₜ, Aₜ₊₁)
    # P(emp | unemp) = q; P(unemp | unemp) = 1-q
    Vu = U(C) + β*( q*EVe(Aₜ₊₁, log(bb)) + (1-q)*EVu(Aₜ₊₁, log(bb)) )
    return Vu
end

#============================
        MaxBellman
============================#
function MyMaxSingleBellmanE(EVe, EVu, Aₜ, lnYₜ)
    # Define a univariate function to maximize over Aₜ₊₁
    to_maximize(Aₜ₊₁) = BellmanE(EVe, EVu, Aₜ, lnYₜ, Aₜ₊₁)
    # Want there to be >0 consumption, so put upper bound
    # at maximum A' that results in C>0, given lnYₜ, Aₜ
    upperA = min(GridA_upper, max_Ap(lnYₜ, Aₜ) - 1e-3)
    # Find the maximizing Aₜ₊₁ for this point in the Aₜ, lnYₜ grid
    out = maximize(to_maximize, GridA_lower, upperA)
    V = maximum(out)
    Aₜ₊₁ = maximizer(out)
    return Aₜ₊₁, V
end

function MyMaxSingleBellmanU(EVe, EVu, Aₜ)
    # Define a univariate function to maximize over Aₜ₊₁
    to_maximize(Aₜ₊₁) = BellmanU(EVe, EVu, Aₜ, Aₜ₊₁)
    # Want there to be >0 consumption, so put upper bound
    # at maximum A' that results in C>0, given lnYₜ=bb, Aₜ
    upperA = min(GridA_upper, max_Ap(log(bb), Aₜ) - 1e-3)
    # Find the maximizing Aₜ₊₁ for Aₜ, lnYₜ=bb
    out = maximize(to_maximize, GridA_lower, upperA)
    V = maximum(out)
    Aₜ₊₁ = maximizer(out)
    return Aₜ₊₁, V
end

function MyMaxBellmanE(EVe::AbstractArray, EVu::AbstractArray)
    # Create interpolation functions (functions of lnYₜ, Aₜ₊₁)
    EVefun = interpolate_EV(EVe)
    EVufun = interpolate_EV(EVu)
    # Define the function taking scalar Aₜ, lnY
    MaxBellmanVector(Aₜ, lnYₜ) = MyMaxSingleBellmanE(EVefun, EVufun, Aₜ, lnYₜ)
    # Broadcast over this function
    out = MaxBellmanVector.(AA, YY)
    maxA = [x[1] for x in out]
    maxBell = [x[2] for x in out]
    return maxBell, maxA
end

function MyMaxBellmanU(EVe::AbstractArray, EVu::AbstractArray)
    # Create interpolation functions (functions of lnYₜ, Aₜ₊₁)
    EVefun = interpolate_EV(EVe)
    EVufun = interpolate_EV(EVu)
    # Define the function taking scalar Aₜ, lnY
    MaxBellmanVector(Aₜ) = MyMaxSingleBellmanU(EVefun, EVufun, Aₜ)
    # Broadcast over this function
    out = MaxBellmanVector.(AA)
    maxA = [x[1] for x in out]
    maxBell = [x[2] for x in out]
    return maxBell, maxA
end

#============================
        Iteration
============================#

"""Update value function and A' lists of vectors with new vectors"""
function update_lists!(Velist, Vulist, Aelist, Aulist, Ve, Vu, Ae, Au)
    append!(Velist, [Ve])
    append!(Vulist, [Vu])
    append!(Aelist, [Ae])
    append!(Aulist, [Au])
end
function update_lists!(Velist, Vulist, Ve, Vu)
    append!(Velist, [Ve])
    append!(Vulist, [Vu])
end

"""Iterate over EV and Ap vectors to converge on the value function and Ap policy rule"""
function MyBellmanIteration(; verbose=true)
    # initial guess of the value functions (zero function)
    MAXIT = 2_000
    Velist, Vulist, Aelist, Aulist = [zeros(size(AA))], [zeros(size(AA))], [zeros(size(AA))], [zeros(size(AA))]
    for it = 1:MAXIT
        Ve, Ape = MyMaxBellmanE(Velist[end], Vulist[end])
        Vu, Apu = MyMaxBellmanU(Velist[end], Vulist[end])

        # take the expectation of the value function from the perspective of the previous A
        # Need to reshape V into a 100x7 array where the rows correspond different levels
        # of assets and the columns correspond to different levels of income.
        # need to take the dot product of each row of the array with the appropriate column of the Markov chain transition matrix
        EVe = reshape(Ve, NA, NY) * GridPY
        EVu = reshape(Vu, NA, NY) * GridPY

        # update our value functions
        update_lists!(Velist, Vulist, Aelist, Aulist, EVe[:], EVu[:], Ape, Apu)

        # see how much our policy rules and value functions have changed
        Aetest = maximum(abs.(Aelist[end] - Aelist[end-1]))
        Autest = maximum(abs.(Aulist[end] - Aulist[end-1]))
        Vetest = maximum(abs.(Velist[end] - Velist[end-1]))
        Vutest = maximum(abs.(Vulist[end] - Vulist[end-1]))
        
        if it % 50 == 0
            verbose ? println("iteration $it, Vetest = $Vetest, Vutest = $Vutest, Aetest = $Aetest, Autest = $Autest") : nothing
        end
        if max(Aetest, Autest, Vetest, Vutest) < 1e-5
            println("\nCONVERGED -- final iteration tests:")
            println("iteration $it, Vetest = $Vetest, Vutest = $Vutest, Aetest = $Aetest, Autest = $Autest")
            break
        end

        it == MAXIT ? println("\nMAX ITERATIONS REACHED ($MAXIT)") : nothing
    end

    return Velist, Vulist, Aelist, Aulist
end

RUNH = true
if RUNH
    outH = @time MyBellmanIteration();
    VeH = outH[1][end]; VuH = outH[2][end]; ApeH = outH[3][end]; ApuH = outH[4][end];
end

PLOTH = true
if PLOTH
    angle0 = (-45,30)
    plotargs = (camera=(-45, 20), xlabel="Y", ylabel="A",
                legend=:none, aspect_ratio=[1,1,2])
    pVe_H = surface(exp.(YY), AA, VeH, zlabel="Ve"; plotargs...)
    pVu_H = surface(exp.(YY), AA, VuH, zlabel="Vu"; plotargs...)
    pApe_H = surface(exp.(YY), AA, ApeH, zlabel="Ape"; plotargs...)
    pApu_H = surface(exp.(YY), AA, ApuH, zlabel="Apu"; plotargs...)
    pCe_H = surface(exp.(YY), AA, c.(YY, AA, ApeH), zlabel="Ce"; plotargs...)
    pCu_H = surface(exp.(YY), AA, c.(log(bb), AA, ApuH), zlabel="Cu"; plotargs...)

    pH1 = plot(pVe_H, pVu_H, pApe_H, pApu_H, pCe_H, pCu_H, 
        layout=(3,2), size=(800, 1600))
    savefig(pH1, "H-all_$GridA_upper")
end
