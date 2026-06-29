# Julia Primer (just enough for CFD)

> You don't need to "learn Julia" first. This page covers ONLY the syntax used in
> the 12 steps. Read section 1–4 before Step 1; the rest is reference.

---

## 0. The big picture

- Julia looks like Python/MATLAB but is **compiled** → fast loops (unlike Python,
  you do NOT need to vectorize everything; plain `for` loops are fast).
- **1-indexed**: the first element is `a[1]`, not `a[0]`. (Python users beware!)
- Blocks end with the keyword `end` (no significant indentation like Python).

---

## 1. Variables & numbers

```julia
nx = 41            # integer
dx = 2.0 / 40      # Float64 (the .0 makes it a float)
c  = 1.0
name = "hat"       # string, double quotes only
```

No type declarations needed. `2.0/40` is float division; `5 ÷ 2` is integer division.

---

## 2. Arrays (the heart of CFD)

```julia
u = ones(41)        # vector of 41 ones      -> Float64
z = zeros(5)        # vector of 5 zeros
u[1]                # FIRST element (1-indexed!)
u[end]              # LAST element
u[2:5]              # elements 2,3,4,5 (a "slice", inclusive on both ends)
length(u)           # 41
un = copy(u)        # IMPORTANT: a real copy. `un = u` would alias the same array!
A = zeros(4, 5)     # a 4x5 matrix (2-D, used from Step 5 on)
A[2, 3]             # row 2, column 3
```

`copy` vs assignment is critical in CFD: `un = u` makes `un` point to the SAME data,
so writing `u[i]` also changes `un[i]`. Always `un = copy(u)`.

---

## 3. Ranges (building the grid)

```julia
range(0, 2, length = 41)   # 41 evenly spaced points from 0 to 2  (this is x)
1:nx                       # integers 1,2,...,nx  (loop counter)
2:nx                       # 2,3,...,nx  (skip the first point)
0.025:0.025:1              # start:step:stop
```

A `range` is a lazy "array-like"; index it `x[i]` or collect with `collect(x)`.

---

## 4. Loops & functions

```julia
for n in 1:nt          # outer time loop
    un = copy(u)
    for i in 2:nx      # inner space loop
        u[i] = un[i] - c*dt/dx * (un[i] - un[i-1])
    end
end

function solve(nx, nt, dx, dt, c)   # define a function
    # ...
    return u                         # explicit return (or last expression)
end
```

Note `end` closes every `for`, `function`, `if`, `begin`.

---

## 5. Broadcasting (the dot `.`) — optional but handy

Putting `.` before an operator applies it **element-wise** across an array:

```julia
u .= 1.0                 # set every element to 1   (.= in-place)
mask = 0.5 .<= x .<= 1.0 # boolean array, true where 0.5≤x≤1
u[mask] .= 2.0           # set those elements to 2
y = sin.(x)              # sin of every element
```

This lets you avoid writing a loop for the initial condition. Either style is fine.

---

## 6. Plotting (Plots.jl)

```julia
using Plots
plot(x, u, label = "initial", lw = 2)     # new plot
plot!(x, u_final, label = "final")        # `plot!` ADDS to the current plot
xlabel!("x"); ylabel!("u")
# 2-D later: heatmap(x, y, A) or surface(x, y, A)
```

The `!` suffix is a Julia convention meaning "this mutates / modifies state"
(here, the current figure). You'll also see it in `push!`, `copy!`, etc.

---

## 7. Pluto specifics

- Each cell holds **one** expression. To run several statements in a cell, wrap
  them in `begin ... end` (see the Step 1 notebook).
- Cells **auto-rerun** when a variable they depend on changes — that's the
  "reactive" magic. Change `nx` and every dependent cell updates live.
- A variable can be assigned in only ONE cell (Pluto enforces this).

---

## Common pitfalls (Python/MATLAB refugees)

| You might write | Correct Julia |
|---|---|
| `u[0]` | `u[1]` (1-indexed) |
| `un = u` (expecting a copy) | `un = copy(u)` |
| `range(0,2,41)` Python-style | `range(0, 2, length=41)` |
| forgetting `end` | every block needs `end` |
| `print(x)` only | `println(x)` adds a newline; in Pluto just put `x` on the last line |
