# Describe Situation
#=
  Allocate $100,000 in client funds across three assets (Tech ETF, Bond Fund, and Gold) to minimise portfolio risk (variance) while achieving a target expected return of 8%.
=#

# Select Packages
using JuMP
using Clarabel
using LinearAlgebra: Symmetric
using Plots

# Select Model
model = Model(Clarabel.Optimizer)

# Define Constants
assets = [:Tech, :Bonds, :Gold]
expected_returns = [0.12, 0.05, 0.07]
expected_returns_dict = Dict{Symbol,Float64}(
    assets[i] => expected_returns[i] for i ∈ 1:3
)

Σ::Symmetric = Symmetric([
    0.040 0.006 -0.004
    0.006 0.010 0.002
    -0.004 0.002 0.0225
])

# Define Variables
@variable(model, w[assets] ≥ 0)

# Define Constraints
@constraint(
    model, portfolio,
    sum(w) == 1.
)

@constraint(
    model, target_return,
    w' * expected_returns ≥ 0.08
)

# Set Objective
@objective(model, Min, w' * Σ * w)

# Run Solver
optimize!(model)

# Display Results
## Objective Value (Risk)
objective_value(model)

## Target Return
value(target_return)

## Decision Quantity
# value(w)
println("Portfolio:")
for asset ∈ assets
    println("\t", asset, " => ", round(value(w[asset]) * 100, digits=2), "%")
end

# Report Conclusion
#=
  To minimise portfolio variance to 0.00888 while achieving a target return of 8%, invest 32.1% ($32,060) in the Tech ETF, 30.2% ($30,180) in the Bond Fund, and 37.8% ($37,760) in Gold.
=#

# Visualise Conclusion (for nonlinear)
# Suppress Clarabel's console output during the loop
set_silent(model)

targets = 0.05:0.002:0.12
variances = Float64[]
weights_matrix = zeros(length(targets), length(assets))

for (i, t) ∈ enumerate(targets)
    set_normalized_rhs(target_return, t)
    optimize!(model)
    push!(variances, objective_value(model))
    for (j, asset) ∈ enumerate(assets)
        weights_matrix[i, j] = value(w[asset]) * 100
    end
end

# Panel 1: Efficient Frontier Curve
p1 = plot(
    targets .* 100, variances,
    linewidth=2.5, colour=:steelblue, label="Efficient Frontier",
    xlabel="Target Expected Return (%)", ylabel="Portfolio Variance",
    title="Minimum Risk vs. Target Return"
)
vline!(p1, [8.0], linestyle=:dash, colour=:crimson, label="8% Target")

# Panel 2: Asset Allocation Shift (Stacked Area)
p2 = areaplot(
    targets .* 100, weights_matrix,
    labels=["Tech ETF" "Bond Fund" "Gold"],
    colours=[:forestgreen :slategray :gold],
    fillalpha=0.85, ylims=(0, 100),
    xlabel="Target Expected Return (%)", ylabel="Portfolio Weight (%)",
    title="Optimal Allocation Shift"
)
vline!(p2, [8.0], linestyle=:dash, colour=:crimson, linewidth=2, label="8% Slice")

plot(p1, p2, layout=(1, 2), size=(950, 420))
