# Glossary — plain-language definitions

Look anything up here the moment it feels unfamiliar. Every entry is one sentence.

| Term | Plain meaning |
|---|---|
| PDE (partial differential equation) | An equation about how a quantity changes across **both** space and time. |
| field | A value defined at every point in space (and time), e.g. temperature everywhere in a rod. |
| derivative | A slope: how fast something changes ("rise over run"). |
| `∂` partial derivative | A slope where you change **one** variable and hold the others fixed. |
| `∂u/∂t` | How fast `u` changes in **time** at a fixed spot. |
| `∂u/∂x` | How fast `u` changes across **space** at a fixed instant (its spatial slope). |
| `Δ` (delta) | "A small step in" or "the difference in" — e.g. `Δx`, `Δt`. |
| grid / mesh | The evenly spaced points where we store the numbers. |
| `Δx` | Distance between two neighboring grid points. |
| `Δt` | Length of one time step (one tick). |
| `u[i]` | The value of `u` at grid point number `i` (Julia: 1-indexed). |
| superscript `n` (`u^n`) | Which time step: `n` = now, `n+1` = next instant. |
| discretization | Turning a smooth equation into operations on a finite list of numbers. |
| finite difference | Approximating a derivative as a subtraction of neighbor values over the spacing. |
| stencil | Which neighbouring points a formula reads in order to approximate a derivative. |
| forward difference | `(u[i+1] − u[i]) / Δx` — uses the point to the **right**. In time: `(u^{n+1} − u^n)/Δt`, which is why the future value is the only unknown. |
| backward difference | `(u[i] − u[i−1]) / Δx` — uses the point to the **left**. |
| central difference (1st derivative) | `(u[i+1] − u[i−1]) / (2Δx)` — uses **both** neighbours; more accurate, but unstable for pure convection with a forward time step. |
| central difference (2nd derivative) | `(u[i+1] − 2u[i] + u[i−1]) / Δx²` — the stencil for `∂²u/∂x²`, used from Step 3 on. |
| upwind | Choosing the neighbour on the side the flow is *coming from* (left when the speed is positive). Getting this side wrong makes the scheme blow up, not merely inaccurate. |
| convection / advection | Stuff being carried along by a flow (a shape moving downstream). |
| diffusion | Stuff spreading out and smoothing (heat evening out, ink in water). |
| time marching | Repeatedly updating the whole grid to step forward in time. |
| initial condition (IC) | The starting values of `u` at time 0. |
| boundary condition (BC) | The rule for the values at the edges of the grid. |
| Courant number σ | `c·Δt/Δx`; how far the wave moves per step relative to the grid spacing. |
| CFL condition | A limit (often `σ ≤ 1`) you must respect or the numbers blow up. |
| stability | Whether the numbers stay sensible (stable) or explode to infinity (unstable). |
| numerical diffusion | Artificial smearing introduced by the scheme, not by real physics. |
| Navier–Stokes | The full equations of fluid motion — the final destination (Steps 11–12). |
