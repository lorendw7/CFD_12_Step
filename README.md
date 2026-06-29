# CFD 12 Step

> A **Julia** implementation & gentle learning notes for Computational Fluid
> Dynamics (CFD), adapted from the classic open-source tutorial
> *CFD Python: the 12 steps to Navier-Stokes equations*.

This repo is a **guided, beginner-friendly** walk to the Navier–Stokes equations.
It assumes **weak math/physics** and **little Julia** — every idea is rebuilt from
intuition first. **You write all the code yourself**; the repo only gives you
`# TODO` skeletons, explanations, and self-tests.

## How to use this repo

For each step:
1. **Read** the doc in `docs/` (English). Concept → everyday analogy → minimal math.
2. **Hear** the bilingual walkthrough in chat; ask anything.
3. **Code** it yourself by filling the `# TODO`s in the matching `src/*.jl` Pluto notebook.
4. **Self-check** against the checklist at the bottom of each doc; then I review.

> Pace is one step at a time. Don't move on until the self-test feels easy.

## Setup

Julia 1.10. Packages live in `Project.toml` (already set up: `Pluto`, `PlutoUI`,
`Plots`). To launch the interactive notebooks:

```bash
julia --project=. -e 'using Pluto; Pluto.run()'
```

Then open `src/stepNN_*.jl` from the Pluto home page.

## Learning path

**Phase 0 — Foundations** (read these before any code)
| Doc | What |
|---|---|
| [`docs/math_refresher.md`](docs/math_refresher.md) | The 4 ideas CFD needs (slope, `∂`, `Δ`, grid). Start here. |
| [`docs/julia_primer.md`](docs/julia_primer.md) | Just-enough Julia (arrays, 1-indexing, `copy`, loops, `Plots`). |
| [`docs/glossary.md`](docs/glossary.md) | One-line plain definitions. Look up anything. |
| [`docs/step00_foundations.md`](docs/step00_foundations.md) | One equation becomes one line of code. |

**Phase 1 — 1-D** (build the whole core pattern)
- Step 1 ⭐ — 1-D Linear Convection `docs/step01_linear_convection.md`
- Step 2 — 1-D Nonlinear Convection
- Step 3 — 1-D Diffusion (+ CFL stability)
- Step 4 — 1-D Burgers' Equation

**Phase 2 — 2-D** (same ideas, one more dimension)
- Steps 5–8 — 2-D Linear/Nonlinear Convection, Diffusion, Burgers'

**Phase 3 — Elliptic / iteration**
- Step 9 — 2-D Laplace
- Step 10 — 2-D Poisson

**Phase 4 — Navier–Stokes**
- Step 11 — Cavity Flow (full N-S + pressure Poisson)
- Step 12 — Channel Flow

## Original Source & Copyright

Original Project: [barbagroup/CFDPython](https://github.com/barbagroup/CFDPython)
Original Copyright (c) Barba group. All original intellectual property rights
belong to the original Barba group authors. This repo is a personal,
Julia-language learning adaptation.
