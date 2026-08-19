# The parameters, once and for all

> Every step from here to Step 12 uses the same handful of knobs. Learn them once.
> Companion pages: `glossary.md` (terms), `math_refresher.md` (the maths).

---

## 1. The six names

| Name | In code | Plain meaning | Value so far | Who decides it |
|---|---|---|---|---|
| grid points | `nx` | How many points you store `u` at | `41` | **you** |
| domain length | `L` | Physical length of the pipe | `2.0` | the problem |
| grid spacing | `dx` | Distance between two neighbouring points | `0.05` | **derived** — `L/(nx-1)` |
| number of steps | `nt` | How many ticks to run | `25` | **you** |
| time step | `dt` | Length of one tick | `0.025` | **you**, but limited (see §4) |
| wave speed | `c` | How fast the shape travels (Step 1 only) | `1.0` | the physics |
| diffusion coefficient | `nu` | How eagerly the stuff spreads (Step 3 on) | `0.3` | the physics |

Two more that are never typed in but matter just as much:

| Name | Formula | Meaning | Value so far |
|---|---|---|---|
| total time | `t = nt·dt` | How much physical time you simulated | `0.625` |
| Courant number | `σ = c·dt/dx` | How many cells the wave crosses per tick | `0.5` |
| von Neumann number | `r = nu·dt/dx²` | The diffusion stability number (Step 3 on) | `0.2` |

From Step 3 on the habit flips: instead of typing `dt` and checking the stability
number afterwards, you **choose** the stability number and derive
`dt = r·dx²/nu`. Then refining the grid can never break stability by accident.

---

## 2. How they hang together

```
SPACE      L  ──split into──▶  nx points  ──▶  dx = L/(nx-1)

TIME       dt  ──repeat──▶  nt times      ──▶  t  = nt·dt

LINKED                    σ = speed · dt / dx
```

`dx` and `dt` are **not** independent. `σ` is the chain between them, and `σ ≤ 1`
is the rule that decides whether your run survives.

### Why `nx - 1` and not `nx`?

41 fence posts make 40 gaps, not 41:

```
point:   1     2     3    ...    41
         •-----•-----•--- ... ---•
gap:        1     2       ...  40
```

`dx` is the size of a **gap**, so it is `L/40`, i.e. `L/(nx-1)`. Off-by-one here is
one of the most common beginner bugs, and it shows up as a solution that drifts at
slightly the wrong speed rather than as an error message.

---

## 3. What happens when you turn each knob

| You change | Directly | Then `σ` | Consequence |
|---|---|---|---|
| `nx` up | `dx` down | **up** | Finer picture, less smearing — but you may cross `σ = 1` and explode |
| `dt` up | — | **up** | Reach a given time in fewer steps — but you may explode |
| `dt` down | — | down | Safer and more accurate in time, but more steps and more smearing per unit time |
| `nt` up | — | unchanged | Simulate a longer stretch of time; costs proportionally more work |
| `c` up | — | **up** | Faster wave, and the stability limit tightens |

The trap worth memorising: **refining the grid (`nx` up) makes the scheme *less*
stable, not more.** If you halve `dx` you must also halve `dt` to keep `σ` fixed.

---

## 4. The stability rule

$$\sigma = \frac{c\,\Delta t}{\Delta x} \le 1 \qquad\text{(the CFL condition)}$$

Read it physically: **in one tick the wave must not travel further than one grid
cell.** If it jumps over a cell, that cell never sees the information passing it and
the numbers lose contact with reality.

Rewritten as the thing you actually do:

$$\Delta t \le \frac{\Delta x}{c}$$

From Step 2 on, the speed is not a single constant, so the rule uses the worst point
on the grid and has to be re-checked as the solution changes:

$$\sigma_{\max} = \frac{\max(u)\,\Delta t}{\Delta x} \le 1$$

### Diffusion has its own, harsher rule

Convection limits `dt` through `dx`. Diffusion limits it through `dx²`:

$$r = \frac{\nu\,\Delta t}{\Delta x^{2}} \le \frac{1}{2}
\qquad\Longleftrightarrow\qquad
\Delta t \le \frac{\Delta x^{2}}{2\nu}$$

Because `Δx` is squared, doubling `nx` forces `Δt` down by **four**, so the same
physical time costs eight times the work.

### When both are active, neither rule is the rule

From Step 4 on, convection and diffusion sit in the same equation, and taking the
smaller of the two limits above is **necessary but not sufficient**. Collect the
merged update as a weighted average of the three old values:

```
u[i]_new  =  r·u[i+1]  +  (1 − σ − 2r)·u[i]  +  (σ + r)·u[i-1]
```

The weights sum to 1, so the new value is a genuine average — and cannot leave the
range it averages — exactly while none of them is negative. Only the middle one can
be, so what governs is

$$\sigma + 2r \le 1
\qquad\Longleftrightarrow\qquad
\Delta t \le \frac{1}{\dfrac{u_{\max}}{\Delta x} + \dfrac{2\nu}{\Delta x^{2}}}$$

Measured: `σ = 0.25` with `r = 0.45` clears both separate rules and still dips to
`u = −1.09` with 57 sign changes along the profile. Full derivation in
`step04_burgers.md` §3.3.

The three regimes, all of which you have now seen with your own numbers:

| `σ` | Behaviour |
|---|---|
| `< 1` | Stable, but the scheme smears corners (numerical diffusion) |
| `= 1` | Exact for linear convection — a pure shift, zero smearing. A knife edge |
| `> 1` | Unstable — the solution explodes within a few dozen steps |

---

## 5. Every experiment so far, in one table

Domain `L = 2`, hat initial condition (`u = 2` on `0.5 ≤ x ≤ 1`, else `u = 1`) —
**except the Step 4 rows**, which use `L = 2π`, a periodic ring, and the saw-tooth
taken from the exact solution.

The stability column holds `σ` for the convection runs and `r` for the diffusion
ones — each step's own stability number. Step 4 has both at once, so it also carries
`σ + 2r`, the rule that actually governs (see `step04_burgers.md` §3.3).

Step 4 reports a **front width in grid cells** (`argmin(u) - argmax(u)`). That one
number explains every Step 4 result: the scheme is accurate where the front spans
many cells and invents its own answer where it spans few.

| Run | `nx` | `dx` | `dt` | `σ` / `r` | What came out |
|---|---|---|---|---|---|
| Step 1 baseline | 41 | 0.05 | 0.025 | 0.5 | Hat moved `0.625`, corners rounded off, peak fell `2 → 1.97` |
| Step 1 refined | 81 | 0.025 | 0.025 | **1.0** | Hat moved `0.625` with a **perfectly square** profile — only `1.0` and `2.0` remain in the array |
| Step 1 too fine | 101 | 0.02 | 0.025 | **1.25** | Exploded to `±2750` in 25 steps |
| Step 1, wrong stencil | 41 | 0.05 | 0.025 | 0.5 | Forward (downwind) difference reached `3×10⁶` — **`σ` was legal and it still blew up**; direction beats magnitude |
| Step 2 baseline | 41 | 0.05 | 0.025 | 1.0 (max) | Bump travelled `0.83` in the time the linear one travelled `0.50`; profile asymmetric; the `u = 2` plateau shrank `11 → 1` points |
| Step 2, smaller `dt` | 41 | 0.05 | 0.0125 | 0.5 (max) | The rarefaction ramp on the back face finally appears — but the peak is smeared down to `1.84` |
| Step 3 baseline (`ν = 0.3`) | 41 | 0.05 | 0.001667 | `r = 0.2` | Corners gone by `n=5` while the flat top still sat at `2.0`; peak `2 → 1.995 → 1.950` at `n = 5, 10, 20`; area `0.5500 → 0.5500`; symmetric to `8×10⁻⁵` |
| Step 3 **A** — over the line | 41 | 0.05 | 0.005 | **`r = 0.6`** | Sawtooth blow-up. Peaks *rose*: `2 → 2.12 → 3.48 → 42.9`. Late growth measured `1.3985` per step against the predicted `\|1-4r\| = 1.4`. Area barely moved (`0.505`) — the `+`/`−` teeth cancel inside `sum` |
| Step 3 **B** — refined grid | 81 | 0.025 | 0.000417 | `r = 0.2` | `dt` fell to a **quarter**, so `nt = 20` only reached `t = 0.0083` — the crisper picture is an *earlier* one, not a better one. `nt = 80` reproduces the baseline (max difference `0.035`, the finer grid being the more accurate) at **8× the work** |
| Step 3 **C** — weaker `ν` | 41 | 0.05 | 0.01667 | `r = 0.2` | `ν = 0.03`: `dt` ×10, `t` ×10, profile **bitwise identical** to the baseline (also checked at `ν = 3.0`). Deriving `dt` from `r` cancels `ν` out of the update entirely; only the product `ν·t = 0.01` decides the shape |
| Step 3 **D** — long run | 41 | 0.05 | 0.001667 | `r = 0.2` | `nt = 500`: the bump reaches the clamped ends and starts **leaking**. Area `0.550 → 0.338` (61% left), peak `→ 1.27`, crest drifting from `x = 0.75` toward `x = 1`. By `nt = 5000` only 0.2% remains; the steady state is `u ≡ 1` |
| Step 4 baseline (`ν = 0.07`) | 101 | 0.0628 | 0.004398 | `σ = 0.490`, `r = 0.078`, `σ+2r = 0.65` | Front spans **4 cells** at `t=0`, 10 in the numerical profile at `t_end = 0.4398`. Saw-tooth travels at `≈3.86` (the `+4` of the exact solution). `max_error = 3.753` — but that is *entirely* the front: 91 of 101 points are inside `0.1` and the mean error is `0.184`. Numerical peak `5.717` vs exact `6.039`, lagging **6 cells**. Seam stays at `0.0` |
| Step 4 **A** — `ν = 0.7`, course recipe | 101 | 0.0628 | 0.04398 | `σ = 4.33`, `r = 7.80`, `σ+2r = 19.9` | **`NaN` within a few steps.** `dt = dx·ν` rises ×10 while the diffusion limit `dx²/2ν` falls ×10 — a **100×** swing in `r` (`0.078 → 7.80`). Every curve disappears from the plot, `u_num` being all `NaN`. `t_end` also silently became `4.398`, ten times the baseline |
| Step 4 **A** — `ν = 0.7`, `σ+2r` recipe | 101 | 0.0628 | 0.00166 | `σ = 0.163`, `r = 0.294`, `σ+2r = 0.752` | Front spans **25 cells** (exact) / 27 (numerical) — ten times the viscosity, ten times the width. `max_error = 0.139` and mean `0.024`: **27× better than the baseline on the same grid**. Numerical peak `5.699` vs exact `5.771`, lagging 1 cell. Peak fell `0.41` and the trough rose `0.41` — diffusion moves, it does not destroy |
| Step 4 **B** — `ν = 0.007` | 101 | 0.0628 | 0.006113 | `σ = 0.689`, `r = 0.011`, `σ+2r = 0.710` | Convection binds by 32× (`0.00888` vs `0.282`). Exact front is **2 cells**; the numerical one is **6** — first-order upwind cannot draw a front thinner than two or three cells, so the width on screen is the *scheme's*, not `ν`'s. Shock lags **12 cells**, `max_error = 3.903`, mean `0.382`. Without the exact curve you would read the 6-cell ramp as physics |
| Step 4 **C** — `nx = 201`, `nt = 100` | 201 | 0.0314 | 0.002199 | `σ = 0.490`, `r = 0.156`, `σ+2r = 0.802` | **Trap:** `dt = dx·ν` halved, so `nt = 100` stops at `t = 0.2199`, half the baseline. `max_error = 2.981` looks like progress and is mostly just the shorter run |
| Step 4 **C** — `nx = 201`, `nt = 200` (equal `t`) | 201 | 0.0314 | 0.002199 | `σ = 0.490`, `r = 0.156`, `σ+2r = 0.802` | Front `4 → 8` cells. Honest comparison: `max_error` `3.753 → 3.382` (**−10%**) while the mean falls `0.184 → 0.121` (**−34%**) and points inside `0.1` go 90% → 93%. At a near-discontinuity `max_error` reports only where the shock sits — **use the mean for refinement studies** |
| Step 4 **C** — `nx = 401`, `nt = 400` | 401 | 0.0157 | 0.0011 | `σ = 0.490`, `r = 0.312`, **`σ+2r = 1.11`** | The binding rule **flips to diffusion** (`0.001762` vs `0.002246`) exactly as §3.3 predicts, and the recipe becomes illegal: `r = ν²/Δx` grows as the grid refines. `max_error` *rises* to `4.16`, shock lag `51` cells. Refining a grid under a bad `dt` recipe makes things worse |
| Step 4 **D** — `nu_solver = 0` | 101 | 0.0628 | 0.004398 | `σ = 0.490`, `r = 0`, `σ+2r = 0.49` | Physical viscosity switched off in the scheme alone; peak `5.720` vs `5.717` **with** viscosity — no measurable difference, because the scheme's own numerical diffusion was already the larger of the two. Front `6` cells rather than `10`, and it keeps **thickening with no diffusion term in the equation**: 6 → 8 → 17 → 32 cells at `nt = 100, 300, 1000, 3000`, peak decaying `5.72 → 3.53`. Control run: swap upwind for a central difference (removing the scheme's diffusion) and it blows to `27.8` with negative velocities by `nt = 100`. **The inaccuracy of upwind is what keeps it stable** |

---

## 6. Reading a result: the four questions

Whatever the step, ask these in order.

1. **Did it stay finite?** If `maximum(abs.(u))` is in the thousands, stop — it is a
   stability problem, and nothing else you observe means anything. Check `σ` first.
2. **How far did it travel?** For linear convection the answer must be exactly
   `c · t`. This is the single best correctness check you have, because it is a
   number you can predict before running.
3. **Is it symmetric?** Linear convection smears symmetrically. Any asymmetry —
   gentle on one side, cliff on the other — is the signature of nonlinearity.
4. **What was lost?** Compare the peak with its starting value and the total
   `sum(u)*dx` with its starting value. A falling peak with conserved total means
   the scheme is diffusing, not leaking.

### A fifth question, about the other four

**Does the check still apply?** Every invariant carries a condition. Conservation of
`sum(u .- 1)*dx` holds only *while the bump has not reached the boundaries* — run
Step 3 to `nt = 500` and the clamped ends drain it away, so the check that was
correct at `n = 20` is simply wrong at `n = 500`. Confirm the condition before
trusting the verdict; a ruler used in the wrong place is worse than no ruler.

Two more habits from Step 3, both cheap and both hard-won:

- **Compare at equal physical time `t = nt·dt`, never at equal step count.** Once
  `dt` is derived from the grid, `nt` stops being a measure of anything physical.
- **Each check is blind to whatever it aggregates away.** `sum` and `maximum` are
  immune to order, so no directional bug can ever show up in them — only a
  point-by-point comparison (the symmetry check) sees those. Use them together.
