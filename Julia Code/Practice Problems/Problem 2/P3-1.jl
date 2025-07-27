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
tspan = (0.0, 5000.0)

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
#sol = sol[:, 325000:end]
kappa_x = kappa * sol[1, :]

# Plot phase plane for Z
p1 = plot(
    solution.t,
    sol[3,:],
    xlabel=L"x",
    ylabel=L"pz",
    title="z vs pz",
    margin=2mm,
    legend=false,
    lw=2,
)

# Plot phase plane for Z
p2 = plot(
    sol[2,:],
    sol[4,:],
    xlabel=L"z",
    ylabel=L"pz",
    title="z vs pz",
    margin=2mm,
    legend=false,
    lw=0.5
)

# Define layout for plots
plot_layout = @layout [a b]
# Combine plots into a single layout
plt = plot(
        p1, p2,
        layout=plot_layout, 
        size=(1200, 600), 
        legend=false,
        )

display(plt)