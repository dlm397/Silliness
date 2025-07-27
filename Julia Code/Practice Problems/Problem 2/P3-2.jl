using DifferentialEquations, Plots, LaTeXStrings, Measures, Integrals, Printf

# Parameter
kappa = 0.01

# Initial conditions
x0 = 200  # Using Float64 for consistency
z0 = 1
px0 = 1   # As per your code
pz0 = 0   # As per your code
u0 = [x0, z0, px0, pz0]

# Time span
tspan = (0.0, 5000.0)

# Define system of equations
function system(du, U, k, t)
    X, Z, Px, Pz = U
    du[1] = Px                      # dx/dt
    du[2] = Pz                      # dz/dt
    du[3] = -k * (k * X - Z^2 / 2)  # dPx/dt
    du[4] = Z * (k * X - Z^2 / 2)   # dPz/dt
end

# Solve the ODE problem
ODEsolution = solve(
    ODEProblem(
        system, 
        u0, 
        tspan, 
        kappa
        ),
    dense=true,
    KenCarp5(),
    reltol=1e-15,
    abstol=1e-15,
    )


# Define z-motion potential energy function
function potentialz(Z, X)
    return (0.5 * ((kappa * X - (Z^2 / 2))^2))
end

# Define z-motion Hamiltonian function
function hamiltonianz(X, Z, Pz)
    return ((0.5 * Pz^2) + potentialz(Z, X))
end

# Function to compute z turning points
function z_zero(kx, hz, plus)
    if plus
        return (sqrt(2 * (kx + sqrt(2 * hz))))
    else
        return (sqrt(2 * (kx - sqrt(2 * hz))))
    end
end

function integrate(t_star)
    # Compute values at t_star
    x_star = ODEsolution(t_star)[1]
    z_star = ODEsolution(t_star)[2]
    #px_star = ODEsolution(t_star)[3]
    pz_star = ODEsolution(t_star)[4]

    # Compute H_z* at t_star
    hz_star = hamiltonianz(x_star, z_star, pz_star)
    # Compute kx*
    kx_star = kappa * x_star

    # Determine z_min and z_max based on conditions
    if z_star > 0 && kx_star^2 < 2 * hz_star
        z_max = z_zero(kx_star, hz_star, true)
        z_min = -z_max
    elseif z_star > 0 && kx_star^2 > 2 * hz_star
        z_max = z_zero(kx_star, hz_star, true)
        z_min = z_zero(kx_star, hz_star, false)
    elseif z_star < 0 && kx_star^2 < 2 * hz_star
        z_max = z_zero(kx_star, hz_star, true)
        z_min = -z_max
    elseif z_star < 0 && kx_star^2 > 2 * hz_star
        z_max = -z_zero(kx_star, hz_star, false)
        z_min = -z_zero(kx_star, hz_star, true)
    else # Error handling
        if kx_star^2 == 2 * hz_star
            error("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-=-=-=       
       Conditions for determining z_min and z_max not satified: kx_star = $(kx_star^2), and Hz_star = $(2 * hz_star)
       =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-==-=-=-=-=-=-=-=")
        elseif z_star == 0
            error("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=        
       Conditions for determining z_min and z_max not satified: z_star = $z_star
       =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=") 
        else
            error("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
       Unknown cause, unable to determine z_min and z_max
       =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=")
        end
    end

    # Define the integrand
    function integrand(z, p)
        E, x_star = p
        value = E - potentialz(z, x_star)
        return sqrt(2 * value)
    end

    # Set parameters for the integral
    params = (hz_star, x_star)

    # Solve the integral
    INTSolution = solve(
        IntegralProblem(
            integrand, 
            (z_min, z_max), 
            params
            ), 
        QuadGKJL(),
        reltol=1e-15,
        abstol=1e-15,
        )

    # Compute result
    result = 2 * INTSolution.u
    return result, kx_star
end

selected_times = [1000, 2500, 3900, 500, 2000, 3000]
for tstar in selected_times
    local J, kxstar = integrate(tstar)
    if kxstar < 0
        @printf("At t = %-4.0f  kx = %2.3f  J = %2.5f\n", tstar, kxstar, J)
    else
        @printf("At t = %-4.0f  kx = %-1.3f   J = %2.5f\n", tstar, kxstar, J)
    end
end