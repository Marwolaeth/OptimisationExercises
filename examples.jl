# Optimization Workflow Template

# Describe Situation
# Select Packages
# Select Model
# Define Variables
# Define Constraints
# Set Objective
# Run Solver
# Display Results
# Report Conclusion
# Visualize Conclusion (for nonlinear)

# Example 2: Knapsack Problem from Wikipedia (binary)

# Describe Situation
#=
    Pack the most valuable boxes without overloading the luggage.
    Assume only 1 box of each color is available.
=#

# Select Packages

using JuMP
using HiGHS

# Select Model
model = Model(HiGHS.Optimizer)

# Define Variables
@variable(model, green, Bin) # binary
@variable(model, blue, Bin)
@variable(model, orange, Bin)
@variable(model, yellow, Bin)
@variable(model, grey, Bin)

# Define Constraints
# total weight in kilograms must be less than or equal to 15

@constraint(
    model, weight,
    green * 12 + blue * 2 + orange * 1 + yellow * 4 + grey * 1 ≤ 15
)

# Set Objective
@objective(
    model, Max,
    green * 4 + blue * 2 + orange * 1 + yellow * 10 + grey * 2
)

# Run Solver
optimize!(model)

# Display Results
boxes = [green, blue, orange, yellow, grey]


for box in boxes
    println(box, "\t = ", value(box))
end

value(weight)

objective_value(model)

# Report Conclusion
#=
    A Maximum Dollar value of $15 can be achieved by taking every box,
    except for the Green box, assuming there is only 1 box of each color.
=#

# Example 3: Knapsack Problem from Wikipedia (infinite supply)

# Describe Situation
#=
    Pack the most valuable boxes without overloading the luggage.
    Assume an infinite supply of boxes of each color is available.
=#

# Select Packages

# using JuMP
# using HiGHS

# Select Model
model = Model(HiGHS.Optimizer)

# Define Variables
@variable(model, green ≥ 0, Int)
@variable(model, blue ≥ 0, Int)
@variable(model, orange ≥ 0, Int)
@variable(model, yellow ≥ 0, Int)
@variable(model, grey ≥ 0, Int)

# Define Constraints
# total weight in kilograms must be less than or equal to 15

@constraint(
    model, weight,
    green * 12 + blue * 2 + orange * 1 + yellow * 4 + grey * 1 ≤ 15
)

# Set Objective
@objective(
    model, Max,
    green * 4 + blue * 2 + orange * 1 + yellow * 10 + grey * 2
)

# Run Solver
optimize!(model)

# Display Results
boxes = [green, blue, orange, yellow, grey]

for box in boxes
    println(box, "\t = ", value(box))
end

value(weight)

objective_value(model)

# Report Conclusion
#=
    A Maximum Dollar value of $36 can be achieved by taking 3 Yellow boxes,
    and 3 Gray boxes, assuming an infinite supply of boxes of each color.
=#