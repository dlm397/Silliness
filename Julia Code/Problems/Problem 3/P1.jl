using DifferentialEquations, Plots, LaTeXStrings, Measures, Integrals, Printf

epsilon = 0.001
p0 = 1.5 # 0.2 0.7 1.5
q0 = 0
u0 = [p0, q0]
tspan = (0.0, 1500.0)
P = 0

function system(du, u, P, t)
    p, q = u
    du[1] = 2 * q * (sin(pi * epsilon * t) - 0.5 * q^2)
    du[2] = p
end

function hamiltonian(u, t)
    p, q = u
    return (0.5 * p^2 + potential(u, t))
end

function potential(u, t)
    p, q = u
    return (sin(pi * epsilon * t) - 0.5 * q^2)^2
end

solution = solve(
    ODEProblem(
        system,
        u0,
        tspan,
        P
    ),
    RK4(),
    abstol=1e-9,
    reltol=1e-9,
    dense=true,
)

h = [hamiltonian((i, j), t) for (i, j, t) in zip(solution[1,:], solution[2,:], solution.t)]
pot = [potential((i, j), t) for (i, j, t) in zip(solution[1,:], solution[2,:], solution.t)]

p1 = plot(
    solution.t,
    solution[1,:],
    lw=0.5,
    title="p vs. t",
    xlabel="time",
    ylabel="p"
)

p2 = plot(
    solution.t,
    solution[2,:],
    lw=0.5,
    title="q vs. t",
    xlabel="time",
    ylabel="q"
)

p3 = plot(
    solution.t,
    h,
    lw=2,
    title="H vs. t",
    xlabel="time",
    ylabel="H"
)

p4 = plot(
    solution.t,
    pot,
    lw=0.5,
    title="U vs. t",
    xlabel="time",
    ylabel="U"
)

plot_layout = @layout [a b ; c d]
plt = plot(
    p1, p2, p3, p4,
    size=(800,800)
)

#savefig(plt, "Plots/Math Project/Part 1/p$p0.png")
display(plt)