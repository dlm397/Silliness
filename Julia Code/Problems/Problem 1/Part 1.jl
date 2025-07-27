using Distributions, DifferentialEquations, Plots, Random, LaTeXStrings, Measures

# Parameters
global epsilon = 0.0
global k = 1000.0
global tspan = (0.0, 15.0)  # Time Span
global x0 = 0.001           # Initial angle
global y0 = 2.503           # Initial velocity
global u0 = [x0, y0]        # Initial conditions
global p = [epsilon, k]     # Parameters

function pendulum(du, U, P, T) # Define system
    local X, Y = U
    local e, K = P
    du[1] = Y
    du[2] = -X + e * K * cos(K * (X - T))
end

function hamiltonian(X, Y) # Simplified Hamiltonian
    return (0.5 * (X^2 + Y^2))
end

function hamilitonian_difference(H0, H, abs=false)
    if abs
        return abs(H0 - H)
    else
        return H0 - H
    end
end

solution = solve(
                ODEProblem(     # Define ODE problem
                    pendulum,   # System of equations
                    u0,         # Initial conditions
                    tspan,      # Time span to evaluate
                    p           # Parameters
                    ),  
                RK4(), # Define solver
                abstol=1e-12, # Absolute tolerance, |numeric-solution - exact-solution| <= abstol
                reltol=1e-11, # Relative tolerance, (|numeric-solution - exact-solution| / exact-solution) <= reltol
                dense=true,    # Outputs a dense solution rather than requiring inputs for specific times 
                #maxiters=10000000
                )

# Calculate simplified Hamiltonian values
h = hamiltonian.(solution[1,:], solution[2,:])
#h_diff = hamilitonian_difference.(h[1], h)

# Calculate sampled values
t_sample = range(tspan[1], tspan[2], length=2000)
x_sample = [u[1] for u in solution(t_sample)]
y_sample = [u[2] for u in solution(t_sample)]
h_sample = hamiltonian.(x_sample, y_sample)

# Plot phase space
p1 = plot(
    x_sample,
    y_sample,
    color=:purple, 
    label=nothing, 
    title=latexstring("Phase~Space"),
    xlabel="Angle (x)", 
    ylabel="Velocity (y)"
)
# Plot simplified Hamiltonian
p2 = plot(
    solution.t, 
    h, 
    color=:blue, 
    label=nothing, 
    title=latexstring("Simplified~Hamiltonian"),
    xlabel="Time (t)", 
    ylabel="Hamiltonian (H)",
    ylim=(h[1] - 0.001, h[end] + 0.001)
)
# Velocity vs. Time
p3 = plot(
    solution.t, 
    solution[2,:], 
    color=:orange, 
    label=nothing, 
    #title="Velocity vs. Time", 
    xlabel="Time (t)", 
    ylabel="Velocity (y)",
    ylims=(-y0 - 1, y0 + 1)
)
# Angle vs. Time
p4 = plot(
    solution.t, 
    solution[1,:], 
    color=:blue, 
    label=nothing, 
    #title="Angle vs. Time", 
    xlabel="Time (t)", 
    ylabel="Angle (x)",
    ylims=(-y0 - 1, y0 + 1)
)

# Create plot layout, [a b ; c d] for 2x2 grid, [a b] for single row
plot_layout = @layout [a b]

# Define combination plot
plt = plot(
            p1, p2, 
            layout=plot_layout, 
            size=(1000, 500), 
            suptitle = latexstring("x_0 = ", "$(x0)", ",~y_0 = ", "$(y0)", ",~\\epsilon = ", "$(epsilon)", ",~k = ", "$(k)"),
            margin=5mm
            )

# Display combined plot
display(plt)