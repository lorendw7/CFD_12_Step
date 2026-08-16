### A Pluto.jl notebook ###
# v1.0.1

using Markdown
using InteractiveUtils

# ╔═╡ a2000000-0000-0000-0000-000000000002
begin
	import Pkg
	Pkg.activate(Base.current_project(@__DIR__))
	using Plots
end

# ╔═╡ a2000000-0000-0000-0000-000000000001
md"""
# Step 2 — 1-D Nonlinear Convection

PDE:  ``\frac{\partial u}{\partial t} + u\,\frac{\partial u}{\partial x} = 0``

Update formula:

``u_i^{n+1} = u_i^{n} - u_i^{n}\frac{\Delta t}{\Delta x}(u_i^{n} - u_{i-1}^{n})``

The constant `c` of Step 1 has been replaced by `u` itself: **every point travels at
a speed equal to its own height.** Fill every `# TODO`.
"""

# ╔═╡ a2000000-0000-0000-0000-000000000003
md"## 1. Parameters (same as Step 1 — note there is no `c` any more)"

# ╔═╡ a2000000-0000-0000-0000-000000000004
begin
	nx = 41                 # number of grid points
	L  = 2.0                # domain length
	dx = L / (nx - 1)       # grid spacing Δx
	nt = 50                 # number of time steps
	dt = 0.0125              # time step Δt

	x = range(0, L, length = nx)
end

# ╔═╡ a2000000-0000-0000-0000-000000000005
md"## 2. Initial condition — the same square hat

Write it again from memory. Do not copy-paste it from Step 1."

# ╔═╡ a2000000-0000-0000-0000-000000000006
function initial_condition(x)
	u = ones(length(x))
	# TODO: set u = 2 for all points with 0.5 ≤ x ≤ 1.0, leave the rest = 1.
	u[0.5 .<= x .<= 1.0] .= 2
	return u
end

# ╔═╡ a2000000-0000-0000-0000-000000000007
md"## 3. The nonlinear solver

Identical to Step 1 except for the speed factor. No `c` argument."

# ╔═╡ a2000000-0000-0000-0000-000000000008
function solve_nonlinear(nt)
	u = initial_condition(x)

	for n in 1:nt
		un = copy(u)
		for i in 2:nx
			# TODO: the update formula.
			# Careful: the speed factor is the SAVED value, not the one you
			# are writing on this line.
			u[i] = un[i] - un[i] * dt / dx * (un[i] - un[i - 1])
		end
	end
	return u
end

# ╔═╡ a2000000-0000-0000-0000-000000000009
md"## 4. Your Step 1 solver, for comparison

Bring your own linear solver across from Step 1 — the two curves side by side
are the whole point of this step."

# ╔═╡ a2000000-0000-0000-0000-00000000000a
function solve_linear(nt, c = 1.0)
	u = initial_condition(x)

	for n in 1:nt
		un = copy(u)
		for i in 2:nx
			# TODO: your Step 1 update formula.
			u[i] = un[i] - c *  dt / dx * (un[i] - un[i - 1])
		end
	end
	return u
end

# ╔═╡ a2000000-0000-0000-0000-00000000000b
md"## 5. Compare"

# ╔═╡ a2000000-0000-0000-0000-00000000000c
begin
	plot(x, initial_condition(x), label = "initial", lw = 2, ls = :dash)
	plot!(x, solve_linear(nt),    label = "linear,    n=$nt", lw = 2)
	plot!(x, solve_nonlinear(nt), label = "nonlinear, n=$nt", lw = 2)
	xlabel!("x"); ylabel!("u"); ylims!(0.8, 2.2)
end

# ╔═╡ a2000000-0000-0000-0000-00000000000d
md"## 6. Watch the shape break

Same run, sampled at several times. Look at what happens to the flat top."

# ╔═╡ a2000000-0000-0000-0000-00000000000e
begin
	p = plot(xlabel = "x", ylabel = "u", ylims = (0.8, 2.2))
	for n in (0, 5, 10, 15, 20)
		plot!(p, x, solve_nonlinear(n), label = "n=$n", lw = 2)
	end
	p
end

# ╔═╡ a2000000-0000-0000-0000-00000000000f
md"""
## 7. Self-test

- σ_max at t=0 is $(2.0 * 0.025 / (2.0/40)) — right on the stability limit.
- TODO (in words): why did the nonlinear bump travel about twice as far as the
  linear one?
- TODO (measure): count the grid points still exactly equal to 2.0 at n = 0, 5, 10,
  15, 20. Wider or narrower?
  Hint: `sum(solve_nonlinear(n) .== 2.0)`
- TODO (experiment): raise `dt` to 0.04. Compute σ_max first, predict, then run.
"""

# ╔═╡ Cell order:
# ╟─a2000000-0000-0000-0000-000000000001
# ╠═a2000000-0000-0000-0000-000000000002
# ╟─a2000000-0000-0000-0000-000000000003
# ╠═a2000000-0000-0000-0000-000000000004
# ╟─a2000000-0000-0000-0000-000000000005
# ╠═a2000000-0000-0000-0000-000000000006
# ╟─a2000000-0000-0000-0000-000000000007
# ╠═a2000000-0000-0000-0000-000000000008
# ╟─a2000000-0000-0000-0000-000000000009
# ╠═a2000000-0000-0000-0000-00000000000a
# ╟─a2000000-0000-0000-0000-00000000000b
# ╠═a2000000-0000-0000-0000-00000000000c
# ╟─a2000000-0000-0000-0000-00000000000d
# ╠═a2000000-0000-0000-0000-00000000000e
# ╟─a2000000-0000-0000-0000-00000000000f
