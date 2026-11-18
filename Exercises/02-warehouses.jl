# Describe Situation

#=
  You are expanding a regional logistics network to supply three retail stores (Store A, Store B, Store C) from two potential warehouses (North Hub and South Hub). You want to decide which warehouses to open and how many pallets to ship from each warehouse to each store to minimise total weekly cost.
=#

# Select Packages
using JuMP
using HiGHS

# Select Model
model = Model(HiGHS.Optimizer)

# Define Constants
warehouses = [:North, :South]
stores = [:A, :B, :C]

fixed_cost = Dict(:North => 500, :South => 400)
capacity = Dict(:North => 100, :South => 90)
demand = Dict(:A => 40, :B => 50, :C => 45)

ship_cost = Dict{Tuple{Symbol,Symbol},Int}(
    (:North, :A) => 4, (:North, :B) => 6, (:North, :C) => 9,
    (:South, :A) => 7, (:South, :B) => 5, (:South, :C) => 4
)

# Define Variables
@variable(model, is_open[warehouses], Bin)

@variable(model, ship[warehouses, stores] ≥ 0, Int)

# Define Constraints
@constraints(
    model,
    begin
        capacity_con[wh ∈ warehouses], sum(ship[wh, :]) ≤ (capacity[wh] * is_open[wh])
    end
)

@constraints(
    model,
    begin
        demand_con[store ∈ stores], sum(ship[:, store]) ≥ demand[store]
    end
)

# Set Objective
# @objective(
#     model, Min,
#     sum(fixed_cost[wh] * is_open[wh] for wh ∈ warehouses) +
#         sum(ship_cost[wh, store] * ship[wh, store] for wh ∈ warehouses, store ∈ stores)
# )

wh_cost = [fixed_cost[wh] for wh ∈ warehouses]
shipping_cost = [ship_cost[wh, store] for wh ∈ warehouses, store ∈ stores]
@objective(
    model, Min,
    sum(ship .* shipping_cost) + sum(wh_cost .* is_open)
)

# Run Solver
optimize!(model)

# Display Results
## Objective Value
objective_value(model)

## Decision Variables
value(is_open)
value(ship)

## Constrained Values
println("Utilised Capacity:")
for wh ∈ warehouses
    println(
        "\t", wh, " => ", Int(value(capacity_con[wh]) + capacity[wh]),
        " of ", capacity[wh],
    )
end

println("\nStore Supplies:")
for store ∈ stores
    println("\t", store, " => ", Int(value(demand_con[store])), " of ", demand[store])
end

# Report Conclusion
#=
  To minimise total weekly cost, open both warehouses (North Hub and South Hub). Ship 40 pallets to Store A and 5 pallets to Store B from North Hub, and ship 45 pallets each to Store B and Store C from South Hub, achieving a minimum weekly cost of $1,495.
=#