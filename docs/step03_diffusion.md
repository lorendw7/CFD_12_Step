# Step 3 — 1-D Diffusion

> The first equation with a **second** derivative. New stencil, new stability rule.
> Difficulty: ⭐⭐ (the maths is new; the code is still ~10 lines).
> Prereq: Steps 1–2 finished.

---

## 0. The everyday picture first

Steps 1 and 2 were about **carrying**: a shape gets transported down the canal.
Nothing was ever created, destroyed or smoothed on purpose — it just moved.

Step 3 is the opposite kind of physics: **spreading**.

Drop a spoon of ink into a glass of perfectly still water. Nothing pushes it, there
is no current at all, and yet the blob slowly widens, fades, and after long enough
the whole glass is a uniform pale grey. Same story if you heat one spot of a metal
bar: the hot spot spreads out and flattens.

That is **diffusion**. Two features to hold on to, because they are the exact
opposite of convection:

| | Convection (Steps 1–2) | Diffusion (Step 3) |
|---|---|---|
| what it does | moves the shape | flattens the shape |
| direction | has one — downstream | has none — spreads both ways equally |
| sharp corners | preserved (in exact maths) | destroyed immediately |
| long-time result | shape still travelling | everything flat |

"No direction" is the sentence that decides the whole numerical method, as you will
see in §3.

---

## 1. The equation & physics

$$\frac{\partial u}{\partial t} = \nu\,\frac{\partial^2 u}{\partial x^2}$$

Two things are new.

**`ν` (Greek "nu")** is the **diffusion coefficient** — how eager the stuff is to
spread. Big `ν`, fast spreading (a drop of ink in hot water); small `ν`, slow
(honey). In fluid dynamics `ν` is the *kinematic viscosity*; in heat conduction the
same equation uses thermal diffusivity. It is just a positive number in the code.

**`∂²u/∂x²`** is a *second* derivative: the derivative of the derivative. Read it in
plain words as **curvature** — how much the profile bends.

- Straight line (no bend) → second derivative `= 0`.
- Valley shape (bends upwards, ∪) → second derivative `> 0`.
- Hill shape (bends downwards, ∩) → second derivative `< 0`.

Now read the whole PDE as an English sentence:

> **The rate of change of `u` in time is proportional to how much the profile bends
> at that point.**

Which means: valleys fill in (`∂u/∂t > 0`, they rise), hills sink (`∂u/∂t < 0`),
straight bits do nothing. Everything is dragged toward flat. That is exactly the
ink in the glass.

---

## 2. The second-derivative stencil

We need a finite-difference formula for `∂²u/∂x²`. The answer is the **central
second difference**:

$$\frac{\partial^2 u}{\partial x^2}\bigg|_i \approx
  \frac{u_{i+1} - 2u_i + u_{i-1}}{\Delta x^2}$$

### Where it comes from (Taylor, gently)

Taylor's series says: if you know a function and all its slopes at one point, you
can predict its value a small distance away. One step right and one step left:

$$u_{i+1} = u_i + \Delta x\,u'_i + \frac{\Delta x^2}{2}u''_i + \frac{\Delta x^3}{6}u'''_i + \dots$$
$$u_{i-1} = u_i - \Delta x\,u'_i + \frac{\Delta x^2}{2}u''_i - \frac{\Delta x^3}{6}u'''_i + \dots$$

**Add the two lines.** Every odd-power term (`u'`, `u'''`, …) appears once with `+`
and once with `−`, so it cancels:

$$u_{i+1} + u_{i-1} = 2u_i + \Delta x^2 u''_i + O(\Delta x^4)$$

Rearrange for `u''` and you get the formula above, with an error of order `Δx²`.
That cancellation is worth noticing: it is *why* this stencil is second-order
accurate, i.e. halving `Δx` cuts its error by four, not by two.

### The intuition (this is the part to remember)

Rewrite the numerator by pulling out a 2:

```
u[i+1] - 2u[i] + u[i-1]  =  2 * ( (u[i+1] + u[i-1])/2  -  u[i] )
                                  \_________________/     \___/
                                  average of neighbours    you
```

So the second derivative measures **how far you sit below the average of your two
neighbours**. Below the average (a valley) → positive → you rise. Above it (a peak)
→ negative → you fall. The stencil is a *smoothing* operation, and nothing more.

### Why central is correct here, when it was wrong in Step 1

In Step 1 you were told to use the *backward* (upwind) neighbour, and that using the
wrong side blew the solution up even with a legal `σ`. Information there had a
direction: it came from upstream.

Diffusion has no direction — the left neighbour and the right neighbour matter
exactly equally. A stencil that is symmetric in `i+1` and `i-1` is not just allowed
here, it is the physically honest choice.

---

## 3. Discretization

Time: the same forward difference as always. Space: the new central second
difference.

$$\frac{u_i^{n+1}-u_i^{n}}{\Delta t}
  = \nu\,\frac{u_{i+1}^{n} - 2u_i^{n} + u_{i-1}^{n}}{\Delta x^2}$$

Only `u_i^{n+1}` is unknown, so:

$$u_i^{n+1} = u_i^{n}
  + \frac{\nu\,\Delta t}{\Delta x^{2}}\bigl(u_{i+1}^{n} - 2u_i^{n} + u_{i-1}^{n}\bigr)$$

In code, next to the two formulas you already know:

```
Step 1:   u[i] = un[i] - c     * dt/dx    * (un[i]   - un[i-1])
Step 2:   u[i] = un[i] - un[i] * dt/dx    * (un[i]   - un[i-1])
Step 3:   u[i] = un[i] + nu    * dt/dx^2  * (un[i+1] - 2un[i] + un[i-1])
```

Three differences from the previous steps, all of them deliberate:

1. **A plus sign**, not a minus. Diffusion adds to a valley; convection subtracts
   what flowed past.
2. **`dx^2`**, not `dx`. A second derivative divides by the spacing twice.
3. **The stencil reaches right as well as left** — `un[i+1]` appears. This changes
   the loop range: point `nx` has no right neighbour, so the loop is now
   `for i in 2:nx-1`. Both ends are held fixed at `u = 1` (a *Dirichlet* boundary
   condition), which is physically "the two ends of the bar are clamped at room
   temperature".

---

## 4. Stability: a new and much harsher rule

Convection had `σ = c·Δt/Δx ≤ 1`. Diffusion has its own number, often written `r`
(or the *von Neumann number*):

$$r = \frac{\nu\,\Delta t}{\Delta x^{2}} \le \frac{1}{2}$$

Where the `1/2` comes from, without any analysis: substitute `r` into the update.

$$u_i^{n+1} = (1-2r)\,u_i^{n} + r\,u_{i+1}^{n} + r\,u_{i-1}^{n}$$

The new value is a **weighted average** of the three old values, and the weights are
`r`, `1−2r`, `r` — which add up to exactly 1. As long as all three weights are
positive you are genuinely averaging, and an average can never exceed the largest
value it averages, so nothing can grow. The moment `r > 1/2` the middle weight
`1−2r` turns **negative**, "averaging" becomes amplification, and the solution
explodes. (Compare Step 1's `u[i] = (1−σ)·un[i] + σ·un[i-1]` — the same argument,
the same failure mode.)

Note the *shape* of a diffusion blow-up: neighbouring points fly apart in opposite
directions, so you see a violent zig-zag (`+`, `−`, `+`, `−` …) rather than a smooth
runaway. It is a recognisable fingerprint.

### The `Δx²` is the expensive part

Rearranged for the thing you actually set:

$$\Delta t \le \frac{\Delta x^{2}}{2\nu}$$

`Δx` is **squared**. Double the number of grid points and `Δt` must be cut by
**four**, so reaching the same physical time costs four times as many steps, each of
them twice as big — eight times the work for one refinement. This is why the
practical way to set `Δt` in a diffusion problem is to fix `r` and derive `Δt`:

```
dt = sigma * dx^2 / nu        # with sigma = 0.2, comfortably below 0.5
```

Do that and refining the grid can never accidentally break stability. This penalty
is the standard motivation for *implicit* methods, which are outside the 12 steps —
just know the reason they exist.

---

## 5. The callback to Step 1

In Step 1 you saw the square hat's corners get rounded off and called it *numerical
diffusion*. Now you have the real thing to compare against. The smearing you saw
there was this exact operator, sneaking in uninvited: the upwind scheme is
algebraically equal to exact convection **plus** a diffusion term with an artificial
coefficient of roughly `ν_num = c·Δx(1−σ)/2`.

That explains two earlier observations at once:

- Bigger `Δx` → more artificial `ν` → more smearing. (Coarse grids look blurry.)
- `σ = 1` → the factor `(1−σ)` is zero → **no** artificial diffusion at all, which is
  why that run was pixel-perfect.

---

## 6. What to code (you write this)

Setup:
- `nx = 41`, `L = 2`, so `Δx = 0.05`; the same square hat initial condition.
- `ν = 0.3`.
- `r = 0.2` (call it `sigma` in code), and **derive** `Δt = r·Δx²/ν`.
- `nt = 20` steps.

Algorithm — identical skeleton to Steps 1–2:
1. `un = copy(u)` before the spatial loop.
2. Loop `for i in 2:nx-1` — mind the new upper limit.
3. Apply the update formula, reading only from `un`.
4. Plot the initial hat and several later times on one figure.

**Pitfalls specific to this step:**
- `dx^2`, not `dx`. Silently gives a wrong answer, not an error.
- `2un[i]`, not `2u[i]` — the same read/write trap as before.
- `2:nx-1`. If you leave it as `2:nx` you will index `un[nx+1]` and Julia *will*
  throw a `BoundsError` — that one at least announces itself.

---

## 7. Self-test / checks

- [ ] Compute `r = ν·Δt/Δx²` from your numbers. Is it the `0.2` you asked for?
      What `Δt` did that give?
- [ ] Predict before running: the hat's two vertical faces — do they stay vertical,
      lean over, or slump? Which of the three did Step 2 do, and why is this
      different?
- [ ] Run it. The result should be **symmetric about `x = 0.75`** (the middle of the
      hat), because diffusion has no preferred direction. Check it numerically, not
      by eye.
- [ ] Track the peak `maximum(u)` at `n = 0, 5, 10, 20`. It should fall
      monotonically. Does it ever *rise*? (It must not — averaging cannot create a
      new maximum.)
- [ ] Conservation: compute `sum(u .- 1) * dx` at `n = 0` and at `n = 20`. The bump
      spreads out and flattens, but the **area** under it should stay essentially
      unchanged while it does not reach the boundaries. Does it? What does that tell
      you about where the "lost" height went?
- [ ] Why is the loop `2:nx-1` now, when Steps 1–2 used `2:nx`? Which points are you
      not updating, and what is holding them at their values?
- [ ] Experiment A — set `sigma = 0.6` (so `r > 1/2`) and keep everything else.
      Compute the new `Δt`, predict, then run. Describe the *shape* of the failure,
      and say how it differs visually from the Step 1 blow-up.
- [ ] Experiment B — `nx = 81` with `sigma` fixed at `0.2`. What happened to `Δt`?
      How many steps do you now need to reach the same physical time `t = nt·Δt` as
      the baseline? Do it, and confirm the two results look alike.
- [ ] Experiment C — `ν = 0.03`, ten times smaller, everything else fixed. Predict
      what changes in the picture *and* what changes in `Δt`, then check both.
- [ ] Run to `nt = 500`. What does `u` approach? Sketch the final shape in words and
      explain it from the boundary conditions.

When the boxes are checked, ping me — then Step 4 glues convection and diffusion
into one equation (Burgers') and Phase 1 is done.
