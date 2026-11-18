# Coffee Blends

# Describe Situation

#=
    You manage a specialty coffee roastery that sells two blends: Morning Kick and Velvet Roast. Decide how many kilograms of each blend to produce this week to maximise total profit.
=#

# Select Packages
using JuMP
using HiGHS

# Select Model
model = Model(HiGHS.Optimizer)

# Define Variables
@variable(model, 0 ≤ morning_kick)
@variable(model, 0 ≤ velvet_roast ≤ 90)

# Define Constraints
@constraint(
    model, arabica,
    morning_kick * 0.6 + velvet_roast * 0.8 ≤ 100
)
@constraint(
    model, robusta,
    morning_kick * 0.4 + velvet_roast * 0.2 ≤ 80
)

# Set Objective
@objective(
    model, Max,
    morning_kick * 12 + velvet_roast * 15
)

# Run Solver
optimize!(model)

# Display Results
blends = [morning_kick, velvet_roast]
beans = [arabica, robusta]

for blend ∈ blends
    println(blend, "\t = ", value(blend))
end

for bean ∈ beans
    println(bean, "\t = ", value(bean))
end

objective_value(model)

# Report Conclusion
#=
    A Maximum profit of $2 000 can be achieved by producing and serving
    166 and 2/3 kg of Morning Kick only.
=#

# Bonus: change in the objective from an infinitesimal relaxation of the constraint

shadow_price(arabica)
shadow_price(robusta)