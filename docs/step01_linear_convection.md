# Step 1 — 1-D Linear Convection

> Your first PDE solver. ~30 lines of Julia. Everything later is a variation on this.
> Difficulty: ⭐ (gentlest). Prereqs: `math_refresher.md` + `step00_foundations.md`.

---

## 0. The everyday picture first

Imagine a long, thin canal. You make a single block-shaped bump of water (a "hat")
and the whole bump drifts down the canal at a steady speed, keeping its shape.
That drifting-along is **convection**. Step 1 is just: store that bump as a
list of numbers and let the computer slide it along, one tick at a time.

## 1. The equation & physics

$$\frac{\partial u}{\partial t} + c\,\frac{\partial u}{\partial x} = 0$$

Same equation as Step 0. `u(x,t)` is the water height (or temperature, or density)
at position `x`, time `t`. `c` is a **constant** speed. The exact behavior: the
starting shape just slides right by `c·t`, **unchanged**. It's called *linear*
because `c` is a fixed number — it does not depend on `u` (in Step 2 it will, and
things get more interesting).

---

## 2. Discretization

- Time derivative → **forward difference**.
- Space derivative → **backward difference** (because the wave info comes from the
  left, i.e. *upwind* — we'll discuss why this matters in Step 2).

$$\frac{u_i^{n+1}-u_i^{n}}{\Delta t}
  + c\,\frac{u_i^{n}-u_{i-1}^{n}}{\Delta x}=0$$

Solve for the only unknown `u_i^{n+1}`:

$$u_i^{n+1}=u_i^{n}-c\frac{\Delta t}{\Delta x}\,\bigl(u_i^{n}-u_{i-1}^{n}\bigr)$$

---

## 3. What to code (you write this)

Setup:
- `nx = 41` grid points; domain length `L = 2`, so `Δx = L/(nx-1)`.
- `nt = 25` time steps; `Δt = 0.025`; `c = 1`.
- Initial condition: `u = 1` everywhere, except `u = 2` for `0.5 ≤ x ≤ 1`
  (the square "hat").

Algorithm:
1. Make a copy `un = copy(u)` of the array **before** the spatial loop.
2. For each interior point `i = 2:nx` (Julia is 1-indexed!), apply the update
   formula using `un`, writing into `u`.
3. Repeat for `nt` time steps.
4. Plot `u` vs `x` before and after.

**Critical pitfall:** you must read from the saved `un` and write to `u`. If you
read and write the same array in the loop, you contaminate the result (point `i`
would use the already-updated `i-1`). This is the in-place bug from Step 0 §self-test Q5.

---

## 4. Self-test / checks

- [ ] After `nt=25` steps the hat has **moved right** and its corners are
      **rounded/smeared**. (That smearing is *numerical diffusion* — real, expected.)
- [ ] The hat's peak should still be near 2 but slightly lower. If it shoots above
      2 or oscillates wildly, your scheme is unstable — check `c·Δt/Δx`.
- [ ] Compute the Courant number `σ = c·Δt/Δx`. Is it ≤ 1?
- [ ] Experiment: raise `nx` to 81, keep `nt=25`, `Δt=0.025`. What happens, and why?
      (Hint: `Δx` shrank, so `σ` grew past 1.) Predict before you run.
- [ ] Why `i = 2:nx` and not `i = 1:nx`? What boundary point did you skip and why?

When all boxes are checked, ping me and I'll review your `.jl`/notebook.
