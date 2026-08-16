# CFD 12 Step

[![Julia](https://img.shields.io/badge/Julia-1.10-9558B2?logo=julia&logoColor=white)](https://julialang.org/)
[![Pluto](https://img.shields.io/badge/Notebooks-Pluto.jl-4EC0E4)](https://plutojl.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Adapted from CFDPython](https://img.shields.io/badge/Adapted%20from-barbagroup%2FCFDPython-orange)](https://github.com/barbagroup/CFDPython)

> A **Julia** implementation & gentle learning notes for Computational Fluid
> Dynamics (CFD), adapted from the classic open-source tutorial
> *CFD Python: the 12 steps to Navier-Stokes equations*.

This repo is a **guided, beginner-friendly** walk to the Navier–Stokes equations.
It assumes **weak math/physics** and **little Julia** — every idea is rebuilt from
intuition first. **You write all the code yourself**; the repo only gives you
`# TODO` skeletons, explanations, and self-tests.

**Keywords**: CFD · Navier–Stokes · finite difference · Julia · Pluto notebooks ·
numerical PDE · learn-by-doing

## How to use this repo

For each step:
1. **Read** the doc in `docs/` (English). Concept → everyday analogy → minimal math.
2. **Hear** the bilingual walkthrough in chat; ask anything.
3. **Code** it yourself by filling the `# TODO`s in the matching `src/*.jl` Pluto notebook.
4. **Self-check** against the checklist at the bottom of each doc; then review.

> Pace is one step at a time. Don't move on until the self-test feels easy.

## Setup

Julia 1.10. Packages live in `Project.toml` (already set up: `Pluto`, `PlutoUI`,
`Plots`). To launch the interactive notebooks:

```bash
julia --project=. -e 'using Pluto; Pluto.run()'
```

Then open `src/stepNN_*.jl` from the Pluto home page.

## Project plan & progress

**Phase 0 — Foundations** ✅ *(read these before any code)*

| Doc | What | Status |
|---|---|---|
| [`docs/math_refresher.md`](docs/math_refresher.md) | The 4 ideas CFD needs (slope, `∂`, `Δ`, grid). Start here. | ✅ |
| [`docs/julia_primer.md`](docs/julia_primer.md) | Just-enough Julia (arrays, 1-indexing, `copy`, loops, `Plots`). | ✅ |
| [`docs/glossary.md`](docs/glossary.md) | One-line plain definitions. Look up anything. | ✅ |
| [`docs/parameters.md`](docs/parameters.md) | `nx`, `dx`, `dt`, `σ` — what each knob does, and every experiment's result in one table. | ✅ |
| [`docs/step00_foundations.md`](docs/step00_foundations.md) | One equation becomes one line of code. | ✅ |

**Phase 1 — 1-D** 🔄 *(build the whole core pattern)*

- [x] Step 1 ⭐ — 1-D Linear Convection — [doc](docs/step01_linear_convection.md) · [notebook](src/step01_linear_convection.jl) ✅ *(solved: σ=0.5 diffuses, σ=1 is exact, σ=1.25 blows up)*
- [ ] Step 2 — 1-D Nonlinear Convection — [doc](docs/step02_nonlinear_convection.md) · [notebook](src/step02_nonlinear_convection.jl) *(materials ready — fill the `# TODO`s yourself)*
- [ ] Step 3 — 1-D Diffusion (+ CFL stability)
- [ ] Step 4 — 1-D Burgers' Equation

**Phase 2 — 2-D** *(same ideas, one more dimension)*

- [ ] Step 5 — 2-D Linear Convection
- [ ] Step 6 — 2-D Nonlinear Convection
- [ ] Step 7 — 2-D Diffusion
- [ ] Step 8 — 2-D Burgers' Equation

**Phase 3 — Elliptic / iteration**

- [ ] Step 9 — 2-D Laplace Equation
- [ ] Step 10 — 2-D Poisson Equation

**Phase 4 — Navier–Stokes** 🏁

- [ ] Step 11 — Cavity Flow (full N-S + pressure Poisson)
- [ ] Step 12 — Channel Flow

**Beyond the 12 steps** *(ideas, not commitments)*

- [ ] Stability & accuracy notes (order of convergence experiments)
- [ ] Performance notes: Julia loops vs. vectorized styles, `@views`, benchmarks
- [ ] Gallery of animated results per step

## Repository layout

```
docs/   # Reading material: one markdown per step, plus foundations
src/    # Pluto notebooks with # TODO skeletons — you fill these in
```

## License

Code and notes in this repo are released under the [MIT License](LICENSE).

This project is a personal, Julia-language learning adaptation of
[barbagroup/CFDPython](https://github.com/barbagroup/CFDPython)
(*CFD Python: the 12 steps to Navier-Stokes equations*, © Barba group,
content CC-BY 4.0 / code BSD-3). All original lesson design and intellectual
credit belong to the original authors — thank you, Prof. Lorena Barba and team.
