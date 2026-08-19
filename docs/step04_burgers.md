# Step 4 — 1-D Burgers' Equation

> The two physics you already know, in one equation. No new stencil — but a new
> boundary condition, a new initial condition, and for the first time an **exact
> answer to compare against**.
> Difficulty: ⭐⭐⭐ (the code is a copy-paste merge; the setup around it is the work).
> Prereq: Steps 1–3 finished.

**Step 4 in three lines.**

1. The update is literally Step 2's line **plus** Step 3's term. Nothing else.
2. Both stability rules must hold **at the same time**: `σ = u_max·Δt/Δx ≤ 1` *and*
   `r = ν·Δt/Δx² ≤ 1/2`. The smaller allowed `Δt` wins.
3. The domain now **wraps around** (periodic): the last point's right neighbour is
   the first point. Two extra lines of code, outside the loop.

---

## 0. The everyday picture first

You have met both halves already, separately:

- **Step 2 (nonlinear convection)** — fast bits of the profile overtake slow bits, so
  the front face gets steeper and steeper until it stands vertical. A *shock*.
- **Step 3 (diffusion)** — anything sharp gets smoothed toward the average of its
  neighbours. Corners die on sight.

Step 4 turns both on at once and lets them fight.

The traffic analogy is exact enough to be worth keeping. On a motorway, cars ahead of
you are slower, so the pack bunches up — the density profile steepens into a jam
front (that is convection, `u ∂u/∂x`). But drivers also keep a gap and brake early
when they see brake lights ahead, which blurs the front over some distance (that is
viscosity, `ν ∂²u/∂x²`). The jam front is neither infinitely sharp nor smeared into
nothing: it settles at a **thickness where the two effects exactly balance**.

That balance is the whole point of Step 4, and it is the reason this equation is
called the *toy Navier–Stokes*: the real equations have the same fight in them —
inertia steepening things up, viscosity smoothing them down — plus pressure and
three dimensions. Get the intuition here and Steps 11–12 are the same story with more
bookkeeping.

**How sharp does the front get?** Roughly `ν / u_jump` wide. Small `ν` (thin, runny
fluid) → a very thin front, almost a discontinuity. Large `ν` (honey) → a broad,
gentle ramp. Nothing in this sentence needs physics beyond "viscosity = how gooey".

---

## 1. The equation

$$\frac{\partial u}{\partial t} + u\,\frac{\partial u}{\partial x}
  = \nu\,\frac{\partial^2 u}{\partial x^2}$$

Read left to right as an English sentence:

> How `u` changes in time = (minus) what the flow carries past **+** what viscosity
> smooths out.

Cover the `ν` term with your thumb and you have Step 2 exactly. Cover the `u ∂u/∂x`
term and you have Step 3 exactly. There is genuinely nothing new in the equation —
which is the good news, because everything new in this step is in the *setup*.

---

## 2. Discretization — a merge, not a derivation

You already discretized both pieces. Put them side by side and add:

```
Step 2:   u[i] = un[i] - un[i]*dt/dx   * (un[i] - un[i-1])
Step 3:   u[i] = un[i] + nu   *dt/dx^2 * (un[i+1] - 2un[i] + un[i-1])

Step 4:   u[i] = un[i] - un[i]*dt/dx   * (un[i] - un[i-1])
                       + nu   *dt/dx^2 * (un[i+1] - 2un[i] + un[i-1])
```

In symbols:

$$u_i^{n+1} = u_i^{n}
  - u_i^{n}\frac{\Delta t}{\Delta x}\bigl(u_i^{n}-u_{i-1}^{n}\bigr)
  + \nu\frac{\Delta t}{\Delta x^{2}}\bigl(u_{i+1}^{n}-2u_i^{n}+u_{i-1}^{n}\bigr)$$

Notice the two stencils stay in their own styles, and that is deliberate:

- the **convection** term keeps the *backward* (upwind) difference — information
  still comes from upstream;
- the **diffusion** term keeps the *central* difference — spreading still has no
  preferred direction.

Mixing them up (central for convection) reintroduces exactly the failure you saw in
Step 1's wrong-stencil experiment. The stencil follows the physics, not the taste.

Because the diffusion term reaches to `i+1`, the loop is `for i in 2:nx-1`, same as
Step 3.

---

## 3. What is actually new (three things)

### 3.1 Periodic boundary conditions

Until now both ends were **clamped** at `u = 1` (Dirichlet). Step 4 instead wraps the
domain into a **circle**: the point at `x = 0` and the point at `x = 2π` are the
*same physical place*. Anything that leaves the right edge comes back in at the left.

Picture the domain as a ring road rather than a straight motorway. This is the
standard trick for studying a shape's own evolution without the boundaries
interfering — nothing ever leaves, so there is no leaking like the one that drained
Step 3's bump at `nt = 500`.

In code the interior loop is unchanged; you just add the two missing points by hand
afterwards, applying the same formula with wrapped neighbours:

```
i = 1   : the left neighbour "u[0]"    is really u[nx-1]
i = nx  : the right neighbour "u[nx+1]" is really u[2]
```

Why `nx-1` and `2`, not `nx` and `1`? Because with `x` running `0 … 2π` inclusive,
grid points `1` and `nx` sit on top of each other physically — they are one point
stored twice. Stepping one grid space left of point `1` therefore lands on `nx-1`,
not `nx`. Getting this off by one is the classic Step 4 bug: the answer stays finite
and looks *almost* right, with a small permanent kink at the seam.

Sanity check to run after every step: `u[1]` and `u[nx]` should stay equal to each
other to machine precision. If they drift apart, your wrap is wrong.

### 3.2 A new initial condition — and it is not a hat

The square hat has served its purpose. Step 4 uses a **saw-tooth** profile that comes
from the *known exact solution* of this equation:

$$u(x,t) = -\frac{2\nu}{\phi}\frac{\partial \phi}{\partial x} + 4,
\qquad
\phi(x,t) = \exp\!\left(\frac{-(x-4t)^2}{4\nu(t+1)}\right)
          + \exp\!\left(\frac{-(x-4t-2\pi)^2}{4\nu(t+1)}\right)$$

Do **not** try to feel this formula in your gut — nobody does. Where it comes from:
Burgers' equation is the one nonlinear equation of this course that can be solved on
paper, via a substitution (the *Cole–Hopf transform*) that turns it into the plain
diffusion equation. `φ` is the solution of that easier equation; the formula above
converts it back. That is the entire story, and you can take it as given.

What matters to you is what it *buys*: an exact answer at every `x` and every `t`,
so for the first time you can measure your error instead of merely eyeballing the
picture.

You need `∂φ/∂x` to evaluate `u`. Differentiating one exponential by the chain rule
(`d/dx exp(f) = f'(x)·exp(f)`, and here `f = -(x-a)²/(4ν(t+1))` so
`f' = -2(x-a)/(4ν(t+1)) = -(x-a)/(2ν(t+1))`) gives:

$$\frac{\partial \phi}{\partial x} =
  -\frac{x-4t}{2\nu(t+1)}\exp\!\left(\frac{-(x-4t)^2}{4\nu(t+1)}\right)
  -\frac{x-4t-2\pi}{2\nu(t+1)}\exp\!\left(\frac{-(x-4t-2\pi)^2}{4\nu(t+1)}\right)$$

Both terms have the same shape; write one, copy it, change `4t` to `4t+2π`.

Evaluate at `t = 0` over `x ∈ [0, 2π]` and plot it before you solve anything. You
should see a saw-tooth: `u` rises steadily, then drops off a cliff, and — crucially —
the value at `x = 0` matches the value at `x = 2π`, which is what makes it legal on a
periodic ring.

### 3.3 Two stability rules at once

Convection wants `σ = u_max·Δt/Δx ≤ 1`. Diffusion wants `r = ν·Δt/Δx² ≤ 1/2`. Both
are active, so **both must hold**, and the binding one is whichever gives the smaller
`Δt`:

$$\Delta t \le \min\left(\frac{\Delta x}{u_{\max}},\ \frac{\Delta x^{2}}{2\nu}\right)$$

With the numbers below (`ν = 0.07`, `Δx ≈ 0.063`, `u_max ≈ 7`), work out both limits
before you run and note which one is doing the constraining. The answer flips as you
refine the grid, because one limit shrinks like `Δx` and the other like `Δx²` — that
is worth seeing once with your own numbers.

**But the two separate rules are necessary, not sufficient.** What governs is the
*merged* update, so collect it as a weighted average of the three old values:

```
u[i]_new  =  r·u[i+1]  +  (1 − σ − 2r)·u[i]  +  (σ + r)·u[i-1]
```

The three weights sum to exactly 1. As long as none of them is negative, the new
value is a genuine average of old values — and an average can never leave the range
of the numbers it averages, which is precisely what "stable" means. Only the middle
weight can go negative, so the condition that actually governs is

$$\sigma + 2r \le 1$$

This is strictly stronger than the two rules above. A run with `σ = 0.25` and
`r = 0.45` passes both of them (`0.25 ≤ 1`, `0.45 ≤ 0.5`) yet has `σ + 2r = 1.15`;
measured, that solution develops 57 sign changes along the profile and dips to
`u = −1.09` — negative velocities that no physics put there. Halve `Δt` so that
`σ + 2r = 0.57` and the same run is clean.

Solving `σ + 2r ≤ 1` for `Δt` gives a recipe that does not lie:

$$\Delta t \le \frac{1}{\dfrac{u_{\max}}{\Delta x} + \dfrac{2\nu}{\Delta x^{2}}}$$

In code, with a safety factor and a fixed upper bound for `u_max` (the saw-tooth peak
stays under 8 for every `ν` in these experiments):

```julia
dt = 0.8 / (8/dx + 2*nu/dx^2)
```

Use the literal `8`, not `maximum(u0)`: the parameters cell defines `ν`, which the
exact-solution cell needs, which the cell building `u0` needs — so reaching back for
`u0` in the parameters cell is a cyclic reference and Pluto will refuse it.

The recipe from the original course, `dt = dx * ν`, is **not** a law of nature — just
a choice that happens to satisfy every rule at `ν = 0.07` on a 101-point grid. It
fails in both directions: raise `ν` tenfold and it gives `σ = 4.3`, `r = 7.8`, and
`NaN` within a few steps (Experiment A); refine to `nx = 401` and `r = ν²/Δx` pushes
`σ + 2r` to 1.11 (Experiment C). Check it; never trust it.

---

## 4. What to code (you write this)

Setup:
- `nx = 101`, domain `0 … 2π`, so `dx = 2π/(nx-1)`.
- `ν = 0.07`, `nt = 100`, `dt = dx * ν`.
- Initial condition: `u(x, 0)` from the exact formula above.
- **Periodic** boundaries.

Algorithm:
1. `un = copy(u)`.
2. `for i in 2:nx-1` — the merged update formula.
3. Then the two wrapped end points, `i = 1` and `i = nx`, by hand.
4. Plot the initial saw-tooth, your numerical result at `nt`, and the **exact**
   solution at `t = nt·dt` on the same axes.

**Pitfalls specific to this step:**
- Writing `u[i]` instead of `un[i]` anywhere in the long formula. It is now a long
  line; the read/write trap gets easier to fall into, not harder.
- Wrapping to `nx` / `1` instead of `nx-1` / `2` — no error, just a permanent kink.
- Forgetting that the exact solution must be evaluated at `t = nt·dt`, not at `nt`.
- Sign: convection term **minus**, diffusion term **plus**.

---

## 5. Self-test / checks

- [ ] Before running: compute both `Δt` limits (`Δx/u_max` and `Δx²/2ν`) and the
      actual `dt = dx·ν`. Which rule is binding? By what margin does each hold?
- [ ] Before running: compute `σ + 2r`. It must be `≤ 1`. This is the rule that
      actually governs and it is stricter than the two above — a run can pass both
      of them and still oscillate. Baseline should give `σ + 2r ≈ 0.65`.
- [ ] Plot `u(x, 0)` alone. Is it periodic — is `u[1] == u[nx]` to ~`1e-12`? If not,
      stop; nothing after this matters.
- [ ] Predict, then run: which way does the saw-tooth travel, and roughly how fast?
      (Look at the average value of `u`; it is not the `c = 1` of Step 1.)
- [ ] Overlay numerical vs exact at `nt = 100`. Report
      `maximum(abs.(u_num .- u_exact))`. Where on the profile is the error largest,
      and why there?
- [ ] Periodicity held up: is `u[1] ≈ u[nx]` still true after 100 steps?
- [ ] Something left the right edge and came back on the left — find the time step
      where the front crosses the seam and confirm the wrap looks smooth there.
- [ ] Experiment A — `ν = 0.7` (ten times more viscous), same everything else.
      Keep `dt = dx·ν` for the first run: it blows up to `NaN`, and working out why
      *before* looking is the point (`dt` rises tenfold while the diffusion limit
      `Δx²/2ν` falls tenfold — a hundredfold swing in `r`). Then switch to the
      `σ + 2r` recipe from §3.3 and rerun to see the physics: how wide is the front
      now, in grid cells, and what happened to the error?
- [ ] Experiment B — `ν = 0.007`, using the `σ + 2r` recipe for `dt`. Which rule is
      binding now? Measure the front width in grid cells for both the exact and the
      numerical profile. They will not agree: first-order upwind cannot render a
      front thinner than about two or three cells, so below that width what you see
      is the scheme's own numerical diffusion, not `ν`. This is the check you could
      not do before Step 4 — without the exact curve you would read the numerical
      front as physics.
- [ ] Experiment C — refine to `nx = 201`. **Watch the clock**: with `dt = dx·ν`,
      halving `Δx` halves `dt`, so `nt = 100` now stops at half the physical time.
      Double `nt` to 200 before comparing errors, or you are crediting the grid for
      a shorter run. At equal physical time `max_error` falls only about 10% while
      the *mean* error falls about a third — at a near-discontinuity `max_error`
      reports only the shock's position error and hides the 190 points that did
      improve. Prefer the mean.
- [ ] Experiment C, continued — refine again to `nx = 401` with `dt = dx·ν`. The
      binding rule flips to diffusion, and `σ + 2r` reaches 1.11, so the recipe is
      now illegal and the error *grows*. Redo it with the §3.3 recipe.
- [ ] Experiment D — turn viscosity off in the **solver only**. Setting `ν = 0`
      everywhere does not work: `ν` sits in the denominator of `φ`, so the exact
      solution and the initial condition both collapse to `NaN` and every curve
      vanishes from the plot. Keep `ν = 0.07` for the initial condition and set the
      separate `nu_solver = 0.0` that the notebook defines for exactly this purpose.
      `max_error` is meaningless here — the exact solution solves a different
      equation than the one you are now integrating, so judge the numerical profile
      on its own. What is the equation now? What happens to the front, and what is
      holding the solution together?

Record every result in `docs/parameters.md` §5.

When these are checked, **Phase 1 is done** — you will have built every ingredient of
Navier–Stokes in one dimension. Step 5 does nothing new physically; it just adds a
second dimension, and the pattern you have practised four times repeats with one more
index.
