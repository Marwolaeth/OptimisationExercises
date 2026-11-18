# Describe Situation
#=
  "Our marketing team has £50,000 to spend next quarter across Search Ads and Video Ads. Each £1,000 spent on Search brings in 40 new leads, while Video has diminishing returns—spending `v` thousand pounds brings in `60√v` leads. Legal requires at least £10,000 on Search, and our creative agency charges a £5,000 flat production fee if we run any Video Ads at all."
=#

# Select Packages
using JuMP
using Ipopt

# Select Model
## Baseline Objective Value: All budget spent on Search
baseline_objective = 40 * 50 # Expect 2,000 leads if all spent on Search

model = Model(Ipopt.Optimizer)

# Define Variables
channels = [:Search, :Video]

@variable(model, spend[channels] ≥ 0)

# Define Constraints
@constraint(model, budget, spend[:Search] + spend[:Video] ≤ 45_000)
@constraint(model, legal, spend[:Search] ≥ 10_000)
@constraint(model, option_w_video, spend[:Video] ≥ 0.01) # Every penny counts

# Set Objective
@objective(
    model, Max,
    40 * (spend[:Search] / 1000) + 60 * √(spend[:Video] / 1000)
)

# Run Solver
optimize!(model)

# Display Results
## Objective Value
objective_value(model)

## Decision Variables
value(spend)

# Report Conclusion
objective_value(model) ≥ baseline_objective

#=
  The maximum 2,000 of expected new leads can be achieved by spending the entire budget of £50,000 on Search Ads.
=#

# Experiment
set_normalized_rhs(budget, 50_000)
optimize!(model)
value(spend)
objective_value(model)
set_normalized_rhs(budget, 45_000)
optimize!(model)

# Visualise Conclusion (for nonlinear)