# deen-lupysta

> Maintenance note: this file is a compact landing-page/export summary. Keep detailed installation steps in `docs/installation.md` and only link to them here.

Developer Environment & Luxurious Python Stack — from bare Ubuntu to production-ready CI/CD with AI agent integration.

## Summary

The Luxurious Python Stack is a five-level development workflow for Python projects:

1. **Global System** — Base tools and runtimes
2. **Mamba + Jupyter** — Data science and experimentation
3. **Projects** — Standard Python projects with UV + direnv
4. **CI/CD** — Automated quality gate and publishing
5. **AI Agents** — Structured session workflow with AGENTS.md

Core tools: UV, direnv, ruff, basedpyright, bump-my-version, Just.

The `pyinit` shell function initializes a complete Python project with all conventions, configuration files, CI/CD setup, and AI agent integration in a single command.

## Installation

See `docs/installation.md` for the canonical installation flow. Shell and agent integrations are symlink-based, so updates happen with `git pull` in the repository checkout.

## Key Commands

```shell
pyinit my-project    # Create new project
just check           # Full quality gate
just bump patch      # Version bump
act ds12             # Activate data science env
jl                   # Start Jupyter Lab
```
