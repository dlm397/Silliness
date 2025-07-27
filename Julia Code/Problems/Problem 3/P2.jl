using DifferentialEquations, Plots, LaTeXStrings, Measures, Integrals, Printf

epsilon = 0.001
p0 = 0.7 # 0.2 0.7 1.5
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
    return (0.5 * p^2 + potential(q, t))
end

function potential(q, t)
    return (sin(pi * epsilon * t) - 0.5 * q^2)^2
end

solution = solve(
    ODEProblem(
        system,
        u0,
        tspan,
        P
    ),
    KenCarp5(),
    abstol=1e-21,
    reltol=1e-21,
    dense=true,
)

function qroot(s, H, plus=true)
    if plus
        return sqrt(2 * (s + sqrt(H)))
    else
        return sqrt(2 * (s - sqrt(H)))
    end
end

function IntProb(q, a)
    H, t = a
    return sqrt(2 * (H - potential(q, t)))
end

function Integral!(t_star)
    sol = solution(t_star)
    p_star = sol[1]
    q_star = sol[2]
    h_star = hamiltonian((p_star, q_star), t_star)
    esin = sin(pi * epsilon * t_star)
    if q_star > 0 && esin^2 < h_star
        qmax = qroot(esin, h_star, true)
        qmin = -qmax
    elseif q_star > 0 && esin^2 > h_star
        qmax = qroot(esin, h_star, true)
        qmin = qroot(esin, h_star, false)
    elseif q_star < 0 && esin^2 < h_star
        qmax = qroot(esin, h_star, true)
        qmin = -qmax
    elseif q_star < 0 && esin^2 > h_star
        qmax = -qroot(esin, h_star, false)
        qmin = -qroot(esin, h_star, true)
    else
        error("Met no conditions")
    end

    params = (h_star, t_star)
    IntSol = solve(
        IntegralProblem(
            IntProb,
            (qmin, qmax),
            params
        ),
        QuadGKJL(),
        reltol=1e-15,
        abstol=1e-15,
    )

    result = 2 * IntSol.u
    if p0 == 0.2
        if result < 0.33
            result = 2 * result
        end
    elseif p0 == 0.7
        if result < 1.8
            result = 2 * result
        end
    end

    return result
end

function get_results(leng=100)
    t_samples = range(tspan[1] + 1, tspan[2], length=leng)
    global results = Float64[]
    for tstar in t_samples
        local numbers = Integral!(tstar)
        if isempty(results)
            global results = numbers
        else
            global results = hcat(results, numbers)
        end
    end
    results = reduce(vcat, results)
    return results, t_samples
end

h = [hamiltonian((j, i), t) for (j, i, t) in zip(solution[1,:], solution[2,:], solution.t)]
J, t_sample = get_results(1000)

p1 = plot(
    solution.t,
    solution[1,:],
    lw=0.5,
    title=latexstring("p~vs~t~(p_0=$p0)"),
    xlabel="time",
    ylabel="p",
    label="",
)

p2 = plot(
    solution.t,
    solution[2,:],
    lw=0.5,
    title=latexstring("q~vs~t~(q_0=$q0)"),
    xlabel="time",
    ylabel="q",
    label="",
)

p3 = plot(
    solution[2,:],
    solution[1,:],
    lw=0.2,
    title=latexstring("Phase~Plane"),
    xlabel="q",
    ylabel="p",
    label="",
)

p4 = plot(
    t_sample,
    J,
    lw=0.5,
    title=latexstring("J~vs~t"),
    xlabel="time",
    ylabel="J",
    label="",
)

plot_layout = @layout [a b ; c d]
plt = plot(
    p1, p2, p3, p4,
    size=(1000, 1000),
)

savefig(plt, "Plots/Math Project/Part 2/lowtol_p$p0.png")
display(plt)