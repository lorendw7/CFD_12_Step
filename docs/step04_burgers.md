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

With the numbers below (`ν = 0.07`, `Δx ≈ 0.063`, `u_max ≈ 8`), work out both limits
before you run and note which one is doing the constraining. The answer flips as you
refine the grid, because one limit shrinks like `Δx` and the other like `Δx²` — that
is worth seeing once with your own numbers.

The recipe here follows the original course: `dt = dx * nu`. That is not a law of
nature, just a choice that happens to satisfy both rules comfortably for these
parameters. Check that it does; do not trust it.

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
      Recompute `dt` (it changes!). Predict the front's sharpness first, then look.
- [ ] Experiment B — `ν = 0.007`. Same drill. What is now the binding stability
      rule? Does the numerical front stay as thin as the exact one, or does the
      scheme's own numerical diffusion take over? (Compare against the exact
      solution — this is the check you could not do before Step 4.)
- [ ] Experiment C — refine to `nx = 201` with `dt = dx·ν` again. Does the error
      against the exact solution shrink? By roughly what factor? Is that consistent
      with a first-order-in-time, first-order-upwind scheme?
- [ ] Experiment D — turn viscosity off entirely, `ν = 0` (keep `dt` from the `ν=0.07`
      run so the scheme is otherwise identical). What is the equation now? What
      happens to the front, and what is holding the solution together?

Record every result in `docs/parameters.md` §5.

When these are checked, **Phase 1 is done** — you will have built every ingredient of
Navier–Stokes in one dimension. Step 5 does nothing new physically; it just adds a
second dimension, and the pattern you have practised four times repeats with one more
index.
