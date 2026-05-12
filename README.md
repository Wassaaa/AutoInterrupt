# AutoInterrupt

AutoInterrupt is a tiny Mythic+ quality-of-life addon that keeps your focus interrupt tools ready.

It automatically creates and updates three general macros:

- `AutoFocus`
- `AutoKick`
- `AutoStop`

## Quick Start

1. Install AutoInterrupt.
2. Reload or log in.
3. Open macros with `/m`.
4. Drag `AutoFocus`, `AutoKick`, and `AutoStop` to your bars.

`AutoFocus` sets and marks your focus target. The focus marker defaults to `4`, and can be changed with `/ai marker 1-8`.

`AutoKick` uses the correct interrupt for your current class/spec. It kicks your focus if you have one; if not, it briefly targets a nearby enemy, interrupts it, restores your target, and starts attacking.

`AutoStop` uses a class-appropriate stop/CC spell, prioritizing focus, then mouseover, then current target.

On ready check, AutoInterrupt marks the tank with square and the healer with moon.

## Generated Macros

`AutoFocus`:

```macro
/tm [@focus,exists] 0
/focus [@mouseover,nodead,exists] [@target,nodead,exists][]
/tm [@focus,exists,nodead] 4
```

`AutoKick`:

```macro
#showtooltip <interrupt>
/cast [@focus,exists,nodead,harm] <interrupt>
/stopmacro [@focus,exists,nodead,harm]
/focus target
/cleartarget
/targetenemy
/cast <interrupt>
/target focus
/clearfocus
/startattack
```

`AutoStop`:

```macro
#showtooltip
/cast [@focus,exists,nodead] [@mouseover,exists,nodead] [] <stop>
```
