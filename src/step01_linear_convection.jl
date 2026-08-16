### A Pluto.jl notebook ###
# v1.0.1

using Markdown
using InteractiveUtils

# ╔═╡ a1000000-0000-0000-0000-000000000002
begin
	import Pkg
	Pkg.activate(Base.current_project(@__DIR__))
	using Plots
end

# ╔═╡ a1000000-0000-0000-0000-000000000001
md"""
# Step 1 — 1-D Linear Convection

PDE:  ``\frac{\partial u}{\partial t} + c\,\frac{\partial u}{\partial x} = 0``

Update formula you derived in Step 0:

``u_i^{n+1} = u_i^{n} - c\frac{\Delta t}{\Delta x}(u_i^{n} - u_{i-1}^{n})``

Fill every `# TODO`. Do **not** look up the answer — derive it from `docs/step01_linear_convection.md`.
"""

# ╔═╡ a1000000-0000-0000-0000-000000000003
md"## 1. Parameters"

# ╔═╡ a1000000-0000-0000-0000-000000000004
begin
	nx = 81                 # number of grid points
	L  = 2.0                # domain length
	dx = L / (nx - 1)       # grid spacing Δx
	nt = 25                 # number of time steps
	dt = 0.025              # time step Δt
	c  = 1.0                # wave speed

	# x coordinates of the grid points (a range from 0 to L with nx points)
	x = range(0, L, length = nx)
end

# ╔═╡ a1000000-0000-0000-0000-000000000005
md"## 2. Initial condition — a square hat"

# ╔═╡ a1000000-0000-0000-0000-000000000006
function initial_condition(x, dx)
	u = ones(length(x))
	# TODO: set u = 2 for all points with 0.5 ≤ x ≤ 1.0, leave the rest = 1.
	# Hint: loop over indices, or use a boolean mask  u[0.5 .<= x .<= 1.0] .= 2
	u[0.5 .<= x .<= 1.0] .= 2
	return u
end

# ╔═╡ a1000000-0000-0000-0000-000000000007
md"## 3. The solver"

# ╔═╡ a1000000-0000-0000-0000-000000000008
function solve_linear_convection(nx, nt, dx, dt, c)
	u = initial_condition(x, dx)

	for n in 1:nt
		un = copy(u)                 # save the old time level (do NOT skip this!)
		for i in 2:nx
			# TODO: implement the update formula.
			# u[i] = un[i] - c*dt/dx * (un[i] - un[i-1])
			# Write it yourself from the math — don't paste the hint line.
			u[i] = un[i] - c * dt / dx * (un[i] - un[i-1])
		end
	end
	return u
end

# ╔═╡ a1000000-0000-0000-0000-000000000009
u_final = solve_linear_convection(nx, nt, dx, dt, c)

# ╔═╡ a1000000-0000-0000-0000-00000000000a
md"## 4. Plot — compare initial vs final"

# ╔═╡ a1000000-0000-0000-0000-00000000000b
begin
	plot(x, initial_condition(x, dx), label = "initial", lw = 2)
	plot!(x, u_final, label = "after $nt steps", lw = 2)
	xlabel!("x"); ylabel!("u")
end

# ╔═╡ a1000000-0000-0000-0000-00000000000c
md"""
## 5. Self-test

- Courant number σ = c·dt/dx = $(c*0.025/(2.0/40)) — is it ≤ 1?
- TODO (in words, here): why `i in 2:nx` and not `1:nx`?
- TODO experiment: change `nx = 81` above and re-run. Predict first, then observe.
"""

# ╔═╡ Cell order:
# ╟─a1000000-0000-0000-0000-000000000001
# ╠═a1000000-0000-0000-0000-000000000002
# ╟─a1000000-0000-0000-0000-000000000003
# ╠═a1000000-0000-0000-0000-000000000004
# ╟─a1000000-0000-0000-0000-000000000005
# ╠═a1000000-0000-0000-0000-000000000006
# ╟─a1000000-0000-0000-0000-000000000007
# ╠═a1000000-0000-0000-0000-000000000008
# ╠═a1000000-0000-0000-0000-000000000009
# ╟─a1000000-0000-0000-0000-00000000000a
# ╠═a1000000-0000-0000-0000-00000000000b
# ╟─a1000000-0000-0000-0000-00000000000c
