using Distributions, DifferentialEquations, Plots, Random, LaTeXStrings, Measures

# Parameter
kappa = 0.01
# Initial conditions
x0 = -200
z0 = 3
px0 = 1
pz0 = 0
u0 = [x0, z0, px0, pz0]
# Time span
tspan = (0.0, 100.0)

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
    return (kinetic(Px, Pz) + Potential(X, Z, k))
end

# Define kinetic and potential energy functions
function kinetic(Px, Pz)
    return (0.5 * (Px^2 + Pz^2))
end

function Potential(X, Z, k)
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
                reltol=1e-12,
                abstol=1e-12,
                )

# Convert solution to a matrix
sol = reduce(hcat, solution.u)
# Calculate Hamiltonian values
h = hamiltonian.(solution.u, kappa)
# Calculate kinetic and potential energy values
kin = [kinetic(u[3], u[4]) for u in solution.u]
pot = [Potential(u[1], u[2], kappa) for u in solution.u]

# Plot phase plane for X
p1 = plot(
    sol[1,:],
    sol[3,:],
    xlabel=L"x",
    ylabel=L"p_x",
    title="Phase Plane for X",
    margin=5mm,
    legend=false,
    lw=2
)

# Plot phase plane for Z
p2 = plot(
    sol[2,:],
    sol[4,:],
    xlabel=L"z",
    ylabel=L"p_z",
    margin=5mm,
    legend=false,
    lw=1
)

# Plot total energy over time
p3 = plot(
    solution.t,
    h,
    xlabel=L"t",
    ylabel=L"H",
    margin=5mm,
    legend=false,
    ylim=(minimum(h) - 0.01, maximum(h) + 0.01),
    lw=2
)

# Plot kinetic and potential energy over time
p4 = plot(
    solution.t,
    kin,
    label=L"K",
    xlabel=L"t",
    ylabel=L"Energy",
    title="Kinetic and Potential Energy",
#margin=5mm,
    legend=:topleft,
    ylim=(minimum(pot) - 0.1, maximum(kin) + 0.1),
    lw=1
)
    plot!(
        p4, 
        solution.t, 
        pot, 
        label=L"U", 
        lw=1
        )

# Define layout for plots
plot_layout = @layout [a  b]
# Combine plots into a single layout
params = latexstring("x_0 = $x0,~z_0 = $z0,~p_{x_0} = $px0,~p_{z_0} = $pz0")
plt = plot(
        p2, p3,
        layout=plot_layout, 
        size=(800, 400), 
        legend=false,
        suptitle = "Phase Plane (for z) and Total Energy\n" * params,
        titlefont=font(10, "Courier"),
        top_margin=10mm
        )

# Save and display the plot
display(plt)