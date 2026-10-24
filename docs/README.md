# CFD 12 Step Learning Guide

This page is the learning map for the repository. Lessons live in `docs/`, and
runnable exercises live in `src/`. Use the lessons for concepts and derivations,
then write and run the corresponding code in Pluto.

## Where to start

If this is your first CFD course, follow this order:

1. Read [`math_refresher.md`](math_refresher.md). Focus only on slopes, `∂`, `Δ`,
   and grids.
2. Read sections 1–4 of [`julia_primer.md`](julia_primer.md). Learn arrays,
   indexing, `copy`, and loops.
3. Read [`step00_foundations.md`](step00_foundations.md). Follow how one partial
   differential equation becomes an update formula.
4. Open `src/step01_linear_convection.jl` in Pluto and complete the first solver.

Do not read every lesson at once. Begin with Step 0 and Step 1, finish their
self-checks, and only then continue to Step 2.

## Start the environment

The project uses Julia 1.10. From the repository root, run:

```powershell
julia --version
julia --startup-file=no --project=. -e 'using Pkg; Pkg.instantiate()'
julia --startup-file=no --project=. -e 'using Pluto; Pluto.run()'
```

The first command should report `julia version 1.10.x`. When Pluto opens, enter:

```text
D:\CS\Code\CFD_12_Step\src\step01_linear_convection.jl
```

## Where to write code

- `docs/*.md`: lesson material to read; do not write solver code here.
- `src/*.jl`: Pluto notebooks; write code in their editable cells.
- `Project.toml`: the project's direct dependencies.
- `Manifest.toml`: dependencies locked with Julia 1.10; do not edit it manually.

Some notebooks retain a reference implementation beneath a `# TODO`. For
practice, hide or remove that implementation, derive and type the line yourself,
then compare your result with the reference.

## A repeatable workflow for every step

1. State which step you are starting.
2. Explain the physical picture in plain language.
3. Derive only the update formula needed for the current step.
4. Type and run the code in Pluto.
5. Predict what a parameter change will do before running the experiment.
6. Complete the self-check at the end of the lesson.

## Learning path

| Stage | Topic | Lesson | Code |
|---|---|---|---|
| Foundations | Math, Julia, grids, and update formulas | `math_refresher.md` → `julia_primer.md` → `step00_foundations.md` | No solver yet |
| Step 1 | 1-D linear convection | `step01_linear_convection.md` | `src/step01_linear_convection.jl` |
| Step 2 | 1-D nonlinear convection | `step02_nonlinear_convection.md` | `src/step02_nonlinear_convection.jl` |
| Step 3 | 1-D diffusion | `step03_diffusion.md` | `src/step03_diffusion.jl` |
| Step 4 | 1-D Burgers' equation | `step04_burgers.md` | `src/step04a_warmup.jl` → `src/step04_burgers.jl` |
| Steps 5–12 | 2-D problems and Navier–Stokes | Planned | Planned |

The checkmarks in the root README describe content available in the repository,
not concepts that a learner has already mastered. After each step, review the
experiment results and self-check answers before deciding whether to continue.
