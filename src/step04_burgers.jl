### A Pluto.jl notebook ###
# v1.0.3

using Markdown
using InteractiveUtils

# ╔═╡ a4000000-0000-0000-0000-000000000002
begin
	import Pkg
	Pkg.activate(Base.current_project(@__DIR__))
	using Plots
end

# ╔═╡ a4000000-0000-0000-0000-000000000001
md"""
# Step 4 — 1-D Burgers' Equation

PDE:  ``\frac{\partial u}{\partial t} + u\frac{\partial u}{\partial x} = \nu\frac{\partial^2 u}{\partial x^2}``

Update formula — Step 2's line **plus** Step 3's term, nothing else:

``u_i^{n+1} = u_i^{n} - u_i^{n}\frac{\Delta t}{\Delta x}(u_i^{n}-u_{i-1}^{n})
 + \nu\frac{\Delta t}{\Delta x^{2}}(u_{i+1}^{n}-2u_i^{n}+u_{i-1}^{n})``

What is new is *around* the formula: a **periodic** domain, a **saw-tooth** initial
condition taken from the exact solution, and — for the first time — an exact answer
to measure your error against.

Fill every `# TODO`. Derive it from `docs/step04_burgers.md`, don't guess.
"""

# ╔═╡ a4000000-0000-0000-0000-000000000003
md"""
## 1. Parameters

The domain is `0 … 2π` now, not `0 … 2`. In Julia `2π` is a literal — you can type
`2π` (or `2pi`) directly.

`dt = dx * nu` is the recipe from the course. It is a *choice*, not a law: §3 of your
checks asks you to verify that it satisfies **both** stability rules.
"""

# ╔═╡ a4000000-0000-0000-0000-000000000004
begin
	nx = 101                   # number of grid points
	L  = 2π                    # domain length — a full circle
	dx = L / (nx - 1)          # grid spacing Δx
	nt = 100                   # number of time steps
	nu = 0.07                  # diffusion coefficient ν

	dt = missing               # TODO: dt = dx * nu

	x = range(0, L, length = nx)
end

# ╔═╡ a4000000-0000-0000-0000-000000000005
md"""
## 2. The exact solution

Two small functions. `φ(x,t)` is a sum of two Gaussians; `dφdx(x,t)` is its
`x`-derivative, which the doc spells out for you. Then

``u(x,t) = -\frac{2\nu}{\phi}\frac{\partial\phi}{\partial x} + 4``

Julia notes:
- `exp(z)` is the exponential. `z^2` squares.
- A one-line function is written `f(x, t) = ...` — no `function`/`end` needed.
- Both terms of `dφdx` have the same shape: write one, copy it, replace `4t` by
  `4t + 2π`.
"""

# ╔═╡ a4000000-0000-0000-0000-000000000006
begin
	# TODO: φ(x,t) — the sum of the two exponentials.
	ϕ(x, t) = missing

	# TODO: ∂φ/∂x — same two terms, each multiplied by its chain-rule factor
	#       -(x - a) / (2ν(t+1)),  with a = 4t for the first and a = 4t + 2π for the second.
	dϕdx(x, t) = missing

	# TODO: u_exact(x,t) = -2ν/φ · ∂φ/∂x + 4
	u_exact(x, t) = missing
end

# ╔═╡ a4000000-0000-0000-0000-000000000007
md"""
### Look at it before you solve anything

`u_exact.(x, 0)` — note the dot. It applies the function to every entry of `x` with
`t = 0` held fixed. This is the same broadcasting you used for `.-` and `.<=`, now on
a function of your own.

**Check before moving on:** the first and last values must agree, or the profile is
not periodic and nothing downstream is meaningful.
"""

# ╔═╡ a4000000-0000-0000-0000-000000000008
begin
	u0 = missing               # TODO: the initial profile, u_exact.(x, 0)

	# TODO: report the seam mismatch |u0[1] - u0[nx]|. Should be ~1e-12 or smaller.
	seam_error = missing

	plot(x, u0, lw = 2, xlabel = "x", ylabel = "u", title = "initial saw-tooth")
end

# ╔═╡ a4000000-0000-0000-0000-000000000009
md"""
## 3. The solver

The interior loop is a straight merge of Steps 2 and 3. The new part comes *after*
it: points `1` and `nx` are missing a neighbour, and on a ring their neighbours wrap
around.

Work out for yourself which index is one grid space to the **left** of point `1`, and
which is one space to the **right** of point `nx`. Remember that points `1` and `nx`
are the same physical place stored twice — so the answer is not `nx` and not `1`.
"""

# ╔═╡ a4000000-0000-0000-0000-00000000000a
function solve_burgers(nt)
	u = u_exact.(x, 0)

	for n in 1:nt
		un = copy(u)

		for i in 2:nx-1
			# TODO: the merged update. Minus for convection, plus for diffusion,
			#       dx for the first term, dx^2 for the second, and every value on
			#       the right-hand side read from `un`.
			u[i] = missing
		end

		# TODO: point 1 — same formula, with the wrapped left neighbour.
		u[1] = missing

		# TODO: point nx — same formula, with the wrapped right neighbour.
		u[nx] = missing
	end

	return u
end

# ╔═╡ a4000000-0000-0000-0000-00000000000b
md"""
## 4. Numerical vs exact

The exact solution must be evaluated at the **physical time** `t = nt·dt`, not at
`nt`. Getting this wrong is the single most common way this plot ends up looking
wrong for no apparent reason.
"""

# ╔═╡ a4000000-0000-0000-0000-00000000000c
begin
	t_end = missing            # TODO: physical time after nt steps
	u_num = solve_burgers(nt)
	u_ex  = missing            # TODO: u_exact.(x, t_end)

	q = plot(xlabel = "x", ylabel = "u", title = "Burgers: numerical vs exact")
	plot!(q, x, u0,    label = "t = 0",       lw = 2, ls = :dot)
	plot!(q, x, u_ex,  label = "exact",       lw = 4, alpha = 0.4)
	plot!(q, x, u_num, label = "numerical",   lw = 2)
	q
end

# ╔═╡ a4000000-0000-0000-0000-00000000000d
md"""
## 5. Numerical checks

Numbers, not eyes — same discipline as Step 3.
"""

# ╔═╡ a4000000-0000-0000-0000-00000000000e
begin
	# TODO: the two stability limits on dt, and the dt you actually used.
	dt_convection = missing    # Δx / u_max      (use maximum(u0) for u_max)
	dt_diffusion  = missing    # Δx^2 / (2ν)
	dt_used       = missing

	# TODO: the two stability numbers actually in force.
	sigma_actual = missing     # u_max·dt/dx     — must be ≤ 1
	r_actual     = missing     # ν·dt/dx^2       — must be ≤ 0.5

	# TODO: worst-case error against the exact solution at t_end.
	max_error = missing

	# TODO: is the solution still periodic after nt steps?
	seam_error_end = missing

	(; dt_convection, dt_diffusion, dt_used,
	   sigma_actual, r_actual, max_error, seam_error_end)
end

# ╔═╡ a4000000-0000-0000-0000-00000000000f
md"""
## 6. Experiments

Predict first — write the prediction down — then change the number and run.

- **A.** `nu = 0.7`. `dt` changes too. Predict the front's sharpness, then look.
- **B.** `nu = 0.007`. Which stability rule binds now? Does the numerical front stay
  as thin as the exact one, or does the scheme's own numerical diffusion win?
- **C.** `nx = 201`, `dt = dx·nu` again. Does `max_error` shrink, and by what factor?
- **D.** `nu = 0` (keep the `ν = 0.07` value of `dt`). What equation is this now?
  What happens to the front, and what is holding the solution together?

Record every result in `docs/parameters.md` §5, same as Steps 1–3.
"""

# ╔═╡ Cell order:
# ╟─a4000000-0000-0000-0000-000000000001
# ╠═a4000000-0000-0000-0000-000000000002
# ╟─a4000000-0000-0000-0000-000000000003
# ╠═a4000000-0000-0000-0000-000000000004
# ╟─a4000000-0000-0000-0000-000000000005
# ╠═a4000000-0000-0000-0000-000000000006
# ╟─a4000000-0000-0000-0000-000000000007
# ╠═a4000000-0000-0000-0000-000000000008
# ╟─a4000000-0000-0000-0000-000000000009
# ╠═a4000000-0000-0000-0000-00000000000a
# ╟─a4000000-0000-0000-0000-00000000000b
# ╠═a4000000-0000-0000-0000-00000000000c
# ╟─a4000000-0000-0000-0000-00000000000d
# ╠═a4000000-0000-0000-0000-00000000000e
# ╟─a4000000-0000-0000-0000-00000000000f
