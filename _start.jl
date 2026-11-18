using Pkg
Pkg.activate(".")
Pkg.add(["JuMP", "GLPK", "HiGHS", "Ipopt", "Clarabel", "Plots"])
Pkg.instantiate()
