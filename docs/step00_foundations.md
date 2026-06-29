# Step 0 — From an equation to a loop (gentle version)

> Prerequisite: read `math_refresher.md` first. This page applies those 4 ideas to
> ONE real equation and shows it becoming one line of code. Go slow. No coding yet.
> Any unfamiliar word → `glossary.md`.

---

## 1. Our first equation, in plain words

$$\frac{\partial u}{\partial t} + c\,\frac{\partial u}{\partial x} = 0$$

Don't panic — read it as a sentence. Move the second term to the right:

$$\underbrace{\frac{\partial u}{\partial t}}_{\text{how fast }u\text{ changes in time}}
  = -\,c\,\underbrace{\frac{\partial u}{\partial x}}_{\text{the spatial slope}}$$

In English: **"how fast `u` changes at a spot = (minus) the wave speed `c` times
how slanted `u` is in space."**

Picture a water wave moving right. Where the wave is steep, the water level at a
fixed point changes quickly. Where it's flat, nothing changes. That's all the
equation says. `c` is just the speed the shape travels. This is called
**linear convection**: a shape slides sideways without changing form.

---

## 2. Replace each derivative with a neighbor-subtraction

From the refresher, every derivative ≈ "rise over run" between grid values.

**Time derivative** — compare the same spot `i` now (`n`) vs next tick (`n+1`):

$$\frac{\partial u}{\partial t} \approx \frac{u_i^{\,n+1} - u_i^{\,n}}{\Delta t}$$

(`u_i^{n}` = value at point `i`, now. `u_i^{n+1}` = same point, one tick later.)

**Space derivative** — compare spot `i` with its **left** neighbor `i-1`
(we use the left one because the wave arrives *from the left* — the "upwind" side):

$$\frac{\partial u}{\partial x} \approx \frac{u_i^{\,n} - u_{i-1}^{\,n}}{\Delta x}$$

Substitute both into the equation:

$$\frac{u_i^{\,n+1} - u_i^{\,n}}{\Delta t}
  + c\,\frac{u_i^{\,n} - u_{i-1}^{\,n}}{\Delta x} = 0$$

---

## 3. Solve for the one thing we don't know

Everything with superscript `n` is "now" — already known. The only unknown is
`u_i^{n+1}` (the future). Solve for it like any algebra equation:

1. Move the `c(...)` term to the right.
2. Multiply both sides by `Δt`.

$$\boxed{\;u_i^{\,n+1} = u_i^{\,n} - c\,\frac{\Delta t}{\Delta x}\,
   \bigl(u_i^{\,n} - u_{i-1}^{\,n}\bigr)\;}$$

Read it as: **new value = old value − (a number) × (slope from the left).**
That boxed line is the whole solver. Try the algebra yourself in §self-test Q3.

---

## 4. Why it becomes a loop

The box gives the future value at **one** point `i`. To advance the whole rod by
one tick, apply it at **every** point. To go further in time, repeat. Two loops:

```
for each time step n:
    save a copy of the current numbers   (call it un)
    for each interior point i:
        u[i] = un[i] - c*dt/dx * (un[i] - un[i-1])
```

**Why save a copy `un`?** Each new value must be built from the *old* snapshot.
If you overwrite `u` as you go, point `i` would use the already-changed `i-1` and
give a wrong answer. So: read from `un`, write to `u`. (This is self-test Q5.)

---

## 5. One catch: you can't pick Δt freely (just a heads-up)

If `Δt` is too big relative to `Δx`, the numbers explode to infinity. The ratio
that matters is the **Courant number** `σ = c·Δt/Δx`. For now just know: keep
`σ ≤ 1`. We'll deliberately break this in Step 3 to *see* it blow up — much more
memorable than a rule.

---

## Self-test (try before Step 1 — partial answers welcome, I'll check them)

1. In your own words: what does `∂u/∂t` mean? And `∂u/∂x`? (One line each.)
2. Write the backward-difference approximation of `∂u/∂x` at point `i`.
3. Starting from the discretized equation in §2, do the algebra to get the boxed
   formula. Which derivative used the **left** neighbor, and why the left?
4. If `c = 1`, `Δx = 0.025`, and you want `σ = 0.5`, what is `Δt`?
   (Use `σ = c·Δt/Δx`.)
5. Why must we compute the new `u[i]` from the saved copy `un`, not from `u` itself?

Don't worry about getting all 5 perfect — send what you have and we'll fix it
together. Then we code Step 1.
