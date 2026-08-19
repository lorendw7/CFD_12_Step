### A Pluto.jl notebook ###
# v1.0.3

using Markdown
using InteractiveUtils

# ╔═╡ a4a00000-0000-0000-0000-000000000002
begin
	import Pkg
	Pkg.activate(Base.current_project(@__DIR__))
	using Plots
end

# ╔═╡ a4a00000-0000-0000-0000-000000000001
md"""
# Step 4A — warm-up: convection and diffusion at the same time

A bridge between Step 3 and the full Burgers' equation. Same square hat, same
domain, same everything you already know. **One** thing is new: the update line has
both physics in it at once.

PDE:  ``\frac{\partial u}{\partial t} + u\frac{\partial u}{\partial x} = \nu\frac{\partial^2 u}{\partial x^2}``

There are only three `# TODO`s on this page. Do them one at a time, in order.
"""

# ╔═╡ a4a00000-0000-0000-0000-000000000003
md"""
## 1. Parameters

Nothing new. `nu` is Step 3's diffusion coefficient; `sigma` is Step 3's stability
number `r`, and `dt` is derived from it exactly as before.
"""

# ╔═╡ a4a00000-0000-0000-0000-000000000004
begin
	nx    = 41                 # number of grid points
	L     = 2.0                # domain length
	dx    = L / (nx - 1)       # grid spacing Δx
	nt    = 20                 # number of time steps
	nu    = 0.3                # diffusion coefficient ν
	sigma = 0.2                # stability number r = ν·dt/dx²

	dt = sigma / nu * dx^2               # TODO 1: same as Step 3 — solve r = nu*dt/dx^2 for dt.

	x = range(0, L, length = nx)
end

# ╔═╡ a4a00000-0000-0000-0000-000000000005
md"## 2. Initial condition — the square hat, exactly as in Steps 1–3"

# ╔═╡ a4a00000-0000-0000-0000-000000000006
function initial_condition(x)
	u = ones(length(x))
	u[0.5 .<= x .<= 1.0] .= 2
	return u
end

# ╔═╡ a4a00000-0000-0000-0000-000000000007
md"""
## 3. The solver

The loop range is Step 3's (`2:nx-1`), the boundaries are Step 3's (clamped, left
alone). The only new thing on this page is the line inside the loop.
"""

# ╔═╡ a4a00000-0000-0000-0000-000000000008
function solve_burgers(nt)
	u = initial_condition(x)

	for n in 1:nt
		un = copy(u)
		for i in 2:nx-1
			# TODO 2: Step 2's convection term and Step 3's diffusion term, added.
			u[i] = un[i] - un[i] * dt / dx * (un[i] - un[i - 1]) + nu * dt / dx^2 * (un[i + 1] - 2 * un[i] + un[i - 1])
		end
	end
	return u
end

# ╔═╡ a4a00000-0000-0000-0000-000000000009
md"## 4. Look at it"

# ╔═╡ a4a00000-0000-0000-0000-00000000000a
begin
	p = plot(xlabel = "x", ylabel = "u", ylims = (0.8, 2.2),
	         title = "convection + diffusion")
	plot!(p, x, initial_condition(x), label = "n=0", lw = 2, ls = :dash)
	for n in (5, 10, 20)
		plot!(p, x, solve_burgers(n), label = "n=$n", lw = 2)
	end
	p
end

# ╔═╡ a4a00000-0000-0000-0000-00000000000b
md"""
## 5. One check

Both stability rules are live now, so both numbers must be legal.
"""

# ╔═╡ a4a00000-0000-0000-0000-00000000000c
begin
	u_end = solve_burgers(nt)

	# TODO 3: the two stability numbers actually in force.
	sigma_actual = maximum(u_end) * dt / dx     # convection: u_max·dt/dx, with u_max = maximum(u_end). Must be ≤ 1.
	r_actual     = nu * dt / dx^2     # diffusion:  nu·dt/dx^2.                              Must be ≤ 0.5.

	(; sigma_actual, r_actual, peak = maximum(u_end))
end

# ╔═╡ Cell order:
# ╟─a4a00000-0000-0000-0000-000000000001
# ╠═a4a00000-0000-0000-0000-000000000002
# ╟─a4a00000-0000-0000-0000-000000000003
# ╠═a4a00000-0000-0000-0000-000000000004
# ╟─a4a00000-0000-0000-0000-000000000005
# ╠═a4a00000-0000-0000-0000-000000000006
# ╟─a4a00000-0000-0000-0000-000000000007
# ╠═a4a00000-0000-0000-0000-000000000008
# ╟─a4a00000-0000-0000-0000-000000000009
# ╠═a4a00000-0000-0000-0000-00000000000a
# ╟─a4a00000-0000-0000-0000-00000000000b
# ╠═a4a00000-0000-0000-0000-00000000000c
