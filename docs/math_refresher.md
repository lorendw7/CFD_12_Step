# Math Refresher — start here if the symbols scare you

> No prerequisites. We rebuild the 4 ideas CFD needs, using pictures and everyday
> examples. If you understand this page, every later equation becomes readable.
> Read slowly. There is no code here.

---

## Idea 1 — A derivative is just a slope

Forget the formulas. A **derivative** answers one question:
**"how fast is something changing right here?"**

- Driving a car: your *position* changes over time. How fast? That's your **speed**
  — the derivative of position with respect to time.
- A hill: the ground *height* changes as you walk east. How steep? That's the
  **slope** — the derivative of height with respect to distance.

Notation: `du/dx` is read "the change in `u` for a tiny change in `x`". It's a slope.
Big slope = steep = changing fast. Zero slope = flat = not changing.

That's it. A derivative = a slope = a rate of change.

---

## Idea 2 — The symbol `∂` (partial) is not scary

Sometimes a thing depends on **two** variables at once. Example: the temperature
`u` in a metal rod depends on **where** you are (`x`) **and** **when** it is (`t`).

If we ask "how does temperature change over **time**, standing still at one spot?"
we hold `x` fixed and only let `t` vary. To signal "I'm only changing one variable,
holding the others still," mathematicians swap the straight `d` for a curly `∂`:

- `∂u/∂t` = how `u` changes in **time**, at a fixed location. (Is this spot heating up?)
- `∂u/∂x` = how `u` changes across **space**, at a fixed instant. (Is it hotter to my right?)

Same idea as Idea 1 (a slope), just "one variable at a time." `∂` is pronounced
"partial" or "dee". **Nothing new to fear.**

---

## Idea 3 — Δ (delta) means "a small step / a difference"

The triangle `Δ` just means **"a small amount of"** or **"the difference in"**.

- `Δx` = a small step in space (the gap between two grid points).
- `Δt` = a small step in time (one tick of the clock).
- `u[i+1] − u[i]` = the *difference* in `u` between neighbor points.

Here's the bridge that powers the whole course. A slope is "rise over run":

```
slope  ≈   rise   =  (value at next point) − (value here)   =  u[i+1] − u[i]
           ----      ----------------------------------         -----------
           run            the small step in x                       Δx
```

So a real derivative `∂u/∂x` (continuous, abstract) is **approximated** by a
subtraction of neighbors divided by the spacing (concrete, computable):

```
∂u/∂x  ≈  (u[i+1] − u[i]) / Δx
```

This swap — *derivative → neighbor subtraction* — is **literally all of CFD**.
It's called a **finite difference**. We'll meet three flavors (forward, backward,
central) but they're all just "rise over run."

---

## Idea 4 — A grid: turning a smooth line into a list of numbers

A computer can't hold a smooth curve — only a list of numbers. So we sample the
curve at evenly spaced points:

```
x:   0    0.05  0.10  0.15  ...  2.0
     |-----|-----|-----|-- ... --|
u:  u[1]  u[2]  u[3]  u[4]  ...  u[41]
```

- The gap between points is `Δx`.
- `u[i]` is the value at point number `i`.
- "Solving a PDE on a computer" = **start with the list of numbers `u`, then update
  every number a little, over and over, to march forward in time.**

That's the entire game. Each step of the course is just a different rule for how to
update the numbers.

---

## The one sentence that summarizes everything

> CFD = store a curve as a list of numbers on a grid, approximate every derivative
> as a subtraction of neighbors (Idea 3), and repeatedly nudge the numbers forward
> in time.

When you're comfortable with Ideas 1–4, open `step00_foundations.md`. It just
applies these four ideas to one real equation. See also `glossary.md` for any term.
