# Conventions Reference

Abbreviated names used throughout this codebase follow established Lua and game development conventions. This page exists so you don't have to guess.

---

## LÖVE Callback Parameters

| Parameter | Full meaning | Where it appears |
|---|---|---|
| `dt` | Delta time — seconds elapsed since the last frame | `love.update(dt)` |
| `t` | Config table — pre-populated by LÖVE with engine defaults, mutated in-place | `love.conf(t)` |

### `dt` — delta time

LÖVE calls `love.update` once per frame and passes the time elapsed since the previous frame as a decimal number of seconds (e.g. `0.016` at 60fps). Using `dt` to scale movement and timers ensures the game runs at the same speed regardless of frame rate.

```lua
function love.update(dt)
    dt = math.min(dt, 0.1)  -- cap to avoid large jumps after a stall
    state = game.update(state, dt)
end
```

`dt` is the standard notation for Δt (delta-t) across physics, mathematics, and game development — not a LÖVE-specific invention.

### `t` — config table

LÖVE creates this table, fills it with default values, then passes it to `love.conf` before the engine fully initialises. You mutate the fields you want to change; the rest stay at their defaults.

```lua
function love.conf(t)
    t.window.title = "My Game"
    t.window.width = 1280
end
```

---

## Common Lua Abbreviations

These appear in standard Lua idioms throughout the codebase and standard library.

| Abbreviation | Full meaning | Typical context |
|---|---|---|
| `i` | Index | `for i, value in ipairs(list)` |
| `k` | Key | `for key, value in pairs(table)` |
| `v` | Value | `for key, value in pairs(table)` |

---

## Common Game Development Abbreviations

These are domain-standard terms in game and graphics programming.

| Abbreviation | Full meaning | Typical context |
|---|---|---|
| `x`, `y` | Horizontal and vertical position | Coordinates, positions |
| `w`, `h` | Width and height | Rectangles, window dimensions |
| `dx`, `dy` | Delta x, delta y — change in position per frame | Velocity vectors, movement direction |
| `r`, `g`, `b`, `a` | Red, green, blue, alpha | Colour values (0–1 in LÖVE) |

---

## Further Reading

- [LÖVE wiki — `dt`](https://love2d.org/wiki/dt)
- [LÖVE wiki — Config Files (`love.conf`)](https://love2d.org/wiki/Config_Files)
- [LÖVE wiki — `love.update`](https://love2d.org/wiki/love.update)
