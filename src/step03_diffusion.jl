### A Pluto.jl notebook ###
# v1.0.3

using Markdown
using InteractiveUtils

# ╔═╡ a3000000-0000-0000-0000-000000000002
begin
	import Pkg
	Pkg.activate(Base.current_project(@__DIR__))
	using Plots
end

# ╔═╡ a3000000-0000-0000-0000-000000000001
md"""
# Step 3 — 1-D Diffusion

PDE:  ``\frac{\partial u}{\partial t} = \nu\,\frac{\partial^2 u}{\partial x^2}``

Update formula:

``u_i^{n+1} = u_i^{n} + \frac{\nu\,\Delta t}{\Delta x^2}\bigl(u_{i+1}^{n} - 2u_i^{n} + u_{i-1}^{n}\bigr)``

Three things are new: a **plus** sign, **`dx^2`** instead of `dx`, and a stencil that
reaches **right as well as left** — so the loop must stop at `nx-1`.

Fill every `# TODO`. Derive it from `docs/step03_diffusion.md`, don't guess.
"""

# ╔═╡ a3000000-0000-0000-0000-000000000003
md"""
## 1. Parameters

New here: `nu` (the diffusion coefficient) and `sigma` (the stability number `r`).
`dt` is no longer a number you type — you **derive** it from `sigma`, so that
refining the grid can never break stability by accident.
"""

# ╔═╡ a3000000-0000-0000-0000-000000000004
begin
	nx    = 41                 # number of grid points
	L     = 2.0                # domain length
	dx    = L / (nx - 1)       # grid spacing Δx
	nt    = 500                 # number of time steps
	nu    = 0.3                # diffusion coefficient ν
	sigma = 0.2                # stability number r = ν·Δt/Δx²  (must be ≤ 0.5)

	dt = sigma / nu * dx^2                     # TODO: derive Δt from sigma, dx and nu.
	                           # Julia note: `dx^2` is the square. Watch the algebra
	                           # — r = nu*dt/dx^2, so solve that for dt.

	x = range(0, L, length = nx)
end

# ╔═╡ a3000000-0000-0000-0000-000000000005
md"## 2. Initial condition — the same square hat, third time, still from memory"

# ╔═╡ a3000000-0000-0000-0000-000000000006
function initial_condition(x)
	u = ones(length(x))
	# TODO: set u = 2 for all points with 0.5 ≤ x ≤ 1.0, leave the rest = 1.
	u[0.5 .<= x .<= 1.0] .= 2
	return u
end


# ╔═╡ 6ec428cf-2e00-4678-b8cb-6ac12263b18c
sum(initial_condition(x)), maximum(initial_condition(x))

# ╔═╡ a3000000-0000-0000-0000-000000000007
md"""
## 3. The diffusion solver

Same skeleton as Steps 1–2. Two changes to be careful about:

- the loop range — point `nx` has no right neighbour any more;
- the formula — plus sign, `dx^2`, and `2un[i]` (the **saved** array, as always).
"""

# ╔═╡ a3000000-0000-0000-0000-000000000008
function solve_diffusion(nt)
	u = initial_condition(x)

	for n in 1:nt
		un = copy(u)
		for i in 2:nx-1        # TODO: fix this range.
			# TODO: the update formula.
			u[i] = un[i] + nu * dt/dx^2 * (un[i + 1] - 2 * un[i] + un[i - 1])
		end
	end
	return u
end

# ╔═╡ a3000000-0000-0000-0000-000000000009
md"## 4. Watch it flatten"

# ╔═╡ a3000000-0000-0000-0000-00000000000a
begin
	p = plot(xlabel = "x", ylabel = "u", ylims = (0.8, 2.2), title = "1-D diffusion")
	plot!(p, x, initial_condition(x), label = "n=0", lw = 2, ls = :dash)
	for n in (20, 100, 500)
		plot!(p, x, solve_diffusion(n), label = "n=$n", lw = 2)
	end
	p
end

# ╔═╡ a3000000-0000-0000-0000-00000000000b
md"""
## 5. Numerical checks

Do these with numbers, not with your eyes. Each line answers one question from the
doc's checklist.
"""

# ╔═╡ 223a23a0-b9a7-4492-9642-2842ce1659be
maximum([1, 5, 3])

# ╔═╡ 7fb06411-3248-4ced-a53b-f7d36e07c91b
[1, 5, 3] .- 1

# ╔═╡ df6a6a8c-5509-4e0b-a6a7-5ff2dc3c78f6
sum([1, 5, 3])

# ╔═╡ 9f838c60-aec5-4e00-b502-3dd554d535d1
c = 0.75 / 0.05 + 1

# ╔═╡ 081eae46-b0b8-4c28-b6c8-f2104f6a1333
k = c - 1

# ╔═╡ f028404b-e6be-413f-9f2d-31aec452ecc0
k1 = 41 - c

# ╔═╡ a3000000-0000-0000-0000-00000000000c
begin
	u20 = solve_diffusion(nt)

	# TODO: the stability number actually in force. Should be 0.2.
	r_actual = nu * dt / dx^2

	# TODO: peak height at n = 0, 5, 10, 20 — must fall, never rise.
	peaks = [maximum(solve_diffusion(i)) for i in (0, 5, 10, 20)]

	# TODO: area of the bump above the background, at n = 0 and n = 20.
	# Hint: `sum(u .- 1) * dx`
	area0  = sum(solve_diffusion(0) .- 1) * dx
	area20 = sum(u20 .- 1) * dx

	# TODO: symmetry about x = 0.75. The hat is symmetric and diffusion has no
	# preferred direction, so the profile must stay symmetric.
	# Hint: compare u20 with `reverse(u20)` — but only over the stretch of grid
	# points that is itself centred on x = 0.75. Work out which indices those are.
	w = u20[1:31]
	symmetry_error = maximum(abs.(w .- reverse(w)))

	(; r_actual, peaks, area0, area20, symmetry_error)
end

# ╔═╡ d2495435-2b39-41fe-a38c-f6fb54030aa6
reverse(w)

# ╔═╡ 8f725546-3d21-4311-a5d3-6982982cc658
w .- reverse(w)

# ╔═╡ f8dfbe07-18d0-4947-a47b-cf1aa9405a81
abs.(w .- reverse(w))

# ╔═╡ a3000000-0000-0000-0000-00000000000d
md"""
## 6. Experiments

Predict first — write the prediction down — then change the number and run.

- **A.** `sigma = 0.6`. Compute the new `Δt`, predict, run. Describe the *shape* of
  the failure and how it differs from the Step 1 blow-up.
- **B.** `nx = 81`, `sigma` still `0.2`. What happened to `Δt`? How many steps
  now reach the same physical time `t = nt·Δt` as the baseline? Confirm the two
  pictures agree.
- **C.** `nu = 0.03`. Predict what changes in the picture *and* in `Δt`.
- **D.** `nt = 500`. What does `u` approach, and why?

Record every result in `docs/parameters.md` §5, same as Steps 1–2.
"""

# ╔═╡ Cell order:
# ╟─a3000000-0000-0000-0000-000000000001
# ╠═a3000000-0000-0000-0000-000000000002
# ╟─a3000000-0000-0000-0000-000000000003
# ╠═a3000000-0000-0000-0000-000000000004
# ╟─a3000000-0000-0000-0000-000000000005
# ╠═a3000000-0000-0000-0000-000000000006
# ╠═6ec428cf-2e00-4678-b8cb-6ac12263b18c
# ╟─a3000000-0000-0000-0000-000000000007
# ╠═a3000000-0000-0000-0000-000000000008
# ╟─a3000000-0000-0000-0000-000000000009
# ╠═a3000000-0000-0000-0000-00000000000a
# ╟─a3000000-0000-0000-0000-00000000000b
# ╠═223a23a0-b9a7-4492-9642-2842ce1659be
# ╠═7fb06411-3248-4ced-a53b-f7d36e07c91b
# ╠═df6a6a8c-5509-4e0b-a6a7-5ff2dc3c78f6
# ╠═9f838c60-aec5-4e00-b502-3dd554d535d1
# ╠═081eae46-b0b8-4c28-b6c8-f2104f6a1333
# ╠═f028404b-e6be-413f-9f2d-31aec452ecc0
# ╠═a3000000-0000-0000-0000-00000000000c
# ╠═d2495435-2b39-41fe-a38c-f6fb54030aa6
# ╠═8f725546-3d21-4311-a5d3-6982982cc658
# ╠═f8dfbe07-18d0-4947-a47b-cf1aa9405a81
# ╟─a3000000-0000-0000-0000-00000000000d
