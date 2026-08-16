# Step 2 — 1-D Nonlinear Convection

> One character changes in the code. The physics changes completely.
> Difficulty: ⭐ (the code is easy — the *thinking* is the point).
> Prereq: Step 1 finished and understood.

---

## 0. The everyday picture first

Step 1 was a canal where the whole water bump drifts at one fixed speed `c`, so the
shape never changes.

Now imagine a traffic jam instead. Every car picks its own speed, and the rule is
**"the taller you are, the faster you go."** The tall cars at the top of the bump
race ahead; the short ones at the bottom crawl. The bump cannot possibly keep its
shape — the top runs away from the bottom.

That is the whole of Step 2. Real water waves do exactly this, which is why an ocean
swell arriving at a beach leans forward and finally breaks.

---

## 1. The equation & physics

$$\frac{\partial u}{\partial t} + u\,\frac{\partial u}{\partial x} = 0$$

Compare it with Step 1:

| | Step 1 | Step 2 |
|---|---|---|
| equation | `∂u/∂t + c·∂u/∂x = 0` | `∂u/∂t + u·∂u/∂x = 0` |
| wave speed | `c`, a fixed number you chose | `u`, the solution's own value |
| shape over time | preserved exactly | distorts, steepens, breaks |

The constant `c` has been replaced by `u` itself. That is the entire difference, and
it is what the word **nonlinear** means here: the unknown multiplies its own
derivative, so the equation is no longer a straight-line relationship in `u`.

The consequence is worth stating on its own line, because everything else follows
from it:

> **Every point travels at a speed equal to its own height.**

A point sitting at `u = 2` moves right at speed 2. A point at `u = 1` moves at
speed 1. They cannot stay in formation.

Two things happen at the two edges of a hat-shaped bump:

- Where `u` **drops** as you move right (the front of the bump), the fast material
  behind catches up with the slow material ahead. The profile **compresses** into a
  near-vertical wall. That wall is a **shock**.
- Where `u` **rises** as you move right (the back of the bump), the fast material
  ahead pulls away from the slow material behind, so that edge **stretches out**.

---

## 2. Discretization

Nothing new. Use the same two approximations as Step 1 — forward difference in
time, backward (upwind) difference in space:

$$\frac{u_i^{n+1}-u_i^{n}}{\Delta t}
  + u_i^{n}\,\frac{u_i^{n}-u_{i-1}^{n}}{\Delta x}=0$$

Solve for the unknown:

$$u_i^{n+1}=u_i^{n}-u_i^{n}\,\frac{\Delta t}{\Delta x}\,
  \bigl(u_i^{n}-u_{i-1}^{n}\bigr)$$

Put the Step 1 formula directly above it and stare at the difference:

```
Step 1:   u[i] = un[i] - c     * dt/dx * (un[i] - un[i-1])
Step 2:   u[i] = un[i] - un[i] * dt/dx * (un[i] - un[i-1])
                          ^^^^
```

`c` became `un[i]`. That is the whole code change.

---

## 3. Stability is no longer a fixed number

In Step 1 the Courant number `σ = c·Δt/Δx` was one number you could compute once,
before running anything. Now the speed is different at every point, so:

$$\sigma_i = \frac{u_i\,\Delta t}{\Delta x}$$

There is a *different* `σ` at every grid point, and it **changes as the solution
changes**. What has to stay below 1 is the largest of them:

$$\sigma_{\max} = \frac{\max(u)\,\Delta t}{\Delta x} \le 1$$

With the standard settings (`max(u) = 2`, `Δt = 0.025`, `Δx = 0.05`) you get
`σ_max = 1` exactly — right on the edge. This is the first hint of something that
will matter for the rest of the course: in a real problem you cannot pick `Δt` once
and forget it, because the flow itself decides what `Δt` is allowed.

---

## 4. What to code (you write this)

Same setup as Step 1 — `nx = 41`, `L = 2`, `nt = 25`, `Δt = 0.025`, same square hat
initial condition (`u = 2` on `0.5 ≤ x ≤ 1`, `u = 1` elsewhere).

1. Write `initial_condition` again **from memory**, not by copy-pasting Step 1.
   Retyping it once is how the syntax sticks.
2. Write `solve_nonlinear_convection`. Identical to Step 1's solver except for the
   one term shown above. Note there is no `c` argument any more.
3. Bring your Step 1 solver across so both curves can be plotted together. The
   comparison *is* the lesson.

**The same pitfall as Step 1, and it bites harder here:** the speed factor must be
`un[i]`, the *saved* value, not `u[i]`. Since `u[i]` is the very quantity being
written on that line, using it instead is an easy slip and gives a silently wrong
answer rather than an error.

---

## 5. Self-test / checks

- [ ] Compute `σ_max = max(u)·Δt/Δx` for the starting condition. What is it?
- [ ] Predict before running: after the same number of steps, does the nonlinear hat
      end up *further* right or *less* far right than the linear one? Why?
- [ ] Measure it. Find where the top of the bump (`u ≈ 2`) sits at `nt = 20` in both
      runs. The linear one should have moved about 0.5; the nonlinear one about 1.0.
      Explain the factor of 2 in one sentence.
- [ ] Does the flat plateau at `u = 2` get **wider** or **narrower** as time goes on?
      Count the grid points still holding a value of 2.0 at `n = 0, 5, 10, 15, 20`.
- [ ] The right-hand face of the bump reaches a steep slope and then stops getting
      steeper. What is stopping it? (Hint: it is not physics. Look at what Step 1
      taught you about `Δx` and rounding off corners.)
- [ ] Run to `nt = 40`. The bump is gone and `u` is nearly 1 everywhere. Where did it
      go? Is anything wrong?
- [ ] Push it: raise `Δt` to `0.04` with `nx = 41`. Compute `σ_max` first, predict,
      then run.

When the boxes are checked, ping me and we will look at the shock together.
