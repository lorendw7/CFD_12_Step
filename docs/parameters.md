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
physical time costs eight times the work. Both rules apply at once from Step 4 on,
where convection and diffusion appear in the same equation — the allowed `Δt` is
then the smaller of the two.

The three regimes, all of which you have now seen with your own numbers:

| `σ` | Behaviour |
|---|---|
| `< 1` | Stable, but the scheme smears corners (numerical diffusion) |
| `= 1` | Exact for linear convection — a pure shift, zero smearing. A knife edge |
| `> 1` | Unstable — the solution explodes within a few dozen steps |

---

## 5. Every experiment so far, in one table

Domain `L = 2`, hat initial condition (`u = 2` on `0.5 ≤ x ≤ 1`, else `u = 1`).

The stability column holds `σ` for the convection runs and `r` for the diffusion
ones — each step's own stability number.

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
