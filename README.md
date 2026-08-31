# Dota-Brainiac

A lightweight, explainable Dota 2 bot decision engine built in Lua.

Dota-Brainiac keeps strategy separate from tactics: it evaluates a normalized world snapshot and explains whether a hero should join a fight, without issuing game commands.

## v0.1

- Lua 5.1-compatible, dependency-free modules
- Inspectable fight score, confidence, and reasons
- Deterministic favorable, unsafe, and dead-hero scenarios
- Clean boundary for a future Dota Bot API or Open Hyper AI adapter

## Run checks

```powershell
lua tests/run.lua
```

## Status

Experimental. v0.1 answers one strategic question: **should I join this fight?**
