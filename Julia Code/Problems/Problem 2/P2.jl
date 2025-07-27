using DifferentialEquations, Plots, LaTeXStrings, Measures

# Parameter
kappa = 0.01
# Initial conditions
x0 = 200
z0 = 1
px0 = 1
pz0 = 0
u0 = [x0, z0, px0, pz0]
# Time span
tspan = (0.0, 500.0)

# Define system of equations
function system(du, U, k, t)
    X, Z, Px, Pz = U
    du[1] = Px
    du[2] = Pz
    du[3] = -k * (k * X - Z^2 / 2)
    du[4] = Z * (k * X - Z^2 / 2)
end

# Define Hamiltonian function
function hamiltonian(U, k)
    X, Z, Px, Pz = U
    return (kinetic(Px, Pz) + potential(X, Z, k))
end

# Define kinetic and potential energy functions
function kinetic(Px, Pz)
    return (0.5 * (Px^2 + Pz^2))
end

function potential(X, Z, k)
    return (0.5 * (k * X - Z^2 / 2)^2)
end

# Solve the ODE problem
solution = solve(
                ODEProblem(
                    system,
                    u0,
                    tspan,
                    kappa
                    ),
                RK4(),
                dense=true,
                reltol=1e-9,
                abstol=1e-9,
                )

# Convert solution to a matrix
sol = reduce(hcat, solution.u)
kappa_x = kappa * sol[1, :]
# Calculate Hamiltonian values
h = hamiltonian.(solution.u, kappa)
# Calculate kinetic and potential energy values
kin = [kinetic(u[3], u[4]) for u in solution.u]
pot = [potential(u[1], u[2], kappa) for u in solution.u]

# Plot phase plane for Z
p1 = plot(
    sol[2,:],
    sol[4,:],
    xlabel=L"z",
    ylabel=L"p_z",
    title=latexstring("Phase~Plane~for~z"),
    margin=2mm,
    legend=false,
    lw=0.5
)

# Plot phase plane for Z
p2 = plot(
    kappa_x,
    sol[3,:],
    xlabel=L"\kappa x",
    ylabel=L"p_x",
    title=latexstring("Phase~Plane~for~\\kappa x"),
    margin=2mm,
    legend=false,
    lw=1
)

# Plot total energy over time
p3 = plot(
    solution.t,
    h,
    xlabel=L"t",
    ylabel=L"H",
    title=latexstring("Total~Energy~over~Time"),
    margin=2mm,
    legend=false,
    ylim=(minimum(h) - 0.01, maximum(h) + 0.01),
    lw=2
)

# Define layout for plots
plot_layout = @layout [a b ; c]
# Combine plots into a single layout
plt = plot(
        p1, p2, p3,
        layout=plot_layout, 
        size=(800, 800), 
        legend=false,
        )

# Save and display the plot
display(plt)