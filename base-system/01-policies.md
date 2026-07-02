### Policies

***I do not believe that my rules are universally correct. However, I do believe that consistent rules are better than no rules at all.***

#### Package Manager Policy

Simple guideline on how to install what.

| Layer | Tool | Scope |
|-------|------|-------|
| OS / System | `apt` / `nala` | Core packages, system daemons, C-libraries, compilers |
| GUI Apps | `flatpak` | Desktop applications (sandboxed) |
| Modern CLI | `brew` | CLI tools + TUIs not in apt |
| Python Global | `uv tool` | Python CLI utilities (ruff, basedpyright); `pipx` only as fallback if `uv` is unavailable |
| Python Project | `uv add` / `uv sync` | ALL project dependencies |
| Python Data Science | `mamba install` + `uv pip install` | Heavy C-extensions, CUDA, ML frameworks |
| Node | `pnpm` | All JS/TS dependencies |
| Rust | `cargo` | Rust binaries and project deps |
| Go | `go install` | Go-based CLI tools |
| Java | `sdk` (SDKMAN) | JDK versions + JVM tools |
| Ruby | `gem` / `bundle` | CLI tools + project deps |

#### Working Folder Policy

* Use `cw` to switch to the current working directory
* use `cw .` to make the current directory the working directory.

⚠️ **These policies are recommendations. You are of course free to customize them. <br>
It is only recommended that you set a system once and then stick to it.**

