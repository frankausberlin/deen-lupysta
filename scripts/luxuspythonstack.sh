# _LUXUS_SCRIPT_DIR — absolute path to the directory containing this sourced script
if [ -n "${BASH_SOURCE[0]:-}" ]; then
    _LUXUS_SOURCE="${BASH_SOURCE[0]}"
elif [ -n "${ZSH_VERSION:-}" ]; then
    eval '_LUXUS_SOURCE="${(%):-%N}"'
else
    _LUXUS_SOURCE="$0"
fi
_LUXUS_REAL_SOURCE="$(readlink -f "$_LUXUS_SOURCE" 2>/dev/null || printf '%s\n' "$_LUXUS_SOURCE")"
_LUXUS_SCRIPT_DIR="$(cd "$(dirname "$_LUXUS_REAL_SOURCE")" && pwd)"
unset _LUXUS_SOURCE _LUXUS_REAL_SOURCE





# ─── pyinit ───────────────────────────────────────────────────────────────────
# Luxury Python Project Initializer — initialize a uv-based Python project.
#
# Usage:
#   pyinit                             # initialize current directory as app
#   pyinit my-project                  # create new directory and initialize as app
#   pyinit my-lib --lib                # create new directory and initialize as library
#   pyinit . --lib                     # initialize current directory as library
#   pyinit my-project --python 3.11    # specify Python version
#   pyinit my-project --force          # overwrite existing config (idempotent re-run)
pyinit() {
    # ─── Parse arguments ──────────────────────────────────────────────────────
    local _dir="."
    local _type="--app"
    local _py_version="3.12"
    local _force=0
    local _positional_count=0
    local _prev_arg=""

    for arg in "$@"; do
        case "$arg" in
            --lib)        _type="--lib" ;;
            --force)      _force=1 ;;
            --python=*)   _py_version="${arg#--python=}" ;;
            --python)     ;;  # handled by next-arg logic below
            *)
                # Ignore if this is the value after --python
                if [[ "${_prev_arg:-}" == "--python" ]]; then
                    _py_version="$arg"
                else
                    (( _positional_count++ )) || true
                    if [[ $_positional_count -eq 1 ]]; then
                        _dir="$arg"
                    fi
                fi
                ;;
        esac
        _prev_arg="$arg"
    done

    # ─── Step 1: Create and enter directory ───────────────────────────────────
    if [[ "$_dir" != "." ]]; then
        mkdir -p "$_dir"
        cd "$_dir" || { echo "Error: Cannot enter directory '$_dir'" >&2; return 1; }
    fi

    local PROJECT_NAME
    local PACKAGE_NAME
    PROJECT_NAME="$(basename "$PWD")"
    PACKAGE_NAME="${PROJECT_NAME//-/_}"

    # Validate that the derived package name is a legal Python identifier.
    # Catches: spaces, leading digits (e.g. '123-test' → '123_test'), umlauts,
    # dashes that survived the substitution, dots, and other symbols.
    if [[ ! "$PACKAGE_NAME" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
        echo -e "\e[31mError:\e[0m package name '$PACKAGE_NAME' (derived from directory '$PROJECT_NAME')" >&2
        echo "       is not a valid Python identifier." >&2
        echo "       Allowed: letters, digits, underscores; must not start with a digit." >&2
        echo "       Tip: rename the project directory to use only [A-Za-z0-9_-] and no leading digit." >&2
        return 1
    fi

    echo -e "\e[34m💎 Initializing $_type project '${PROJECT_NAME}' (Python ${_py_version})...\e[0m"
    [[ $_force -eq 1 ]] && echo -e "\e[33m   --force: existing generated files will be overwritten.\e[0m"

    # Helper: write file only if missing (or --force)
    _write_if_missing() {
        local _path="$1"
        if [[ ! -f "$_path" || $_force -eq 1 ]]; then
            return 0  # caller should write
        else
            echo -e "\e[90m   Skipping (exists): $_path\e[0m"
            return 1  # skip
        fi
    }

    # ─── Step 2: UV init with managed Python ──────────────────────────────────
    # Force managed Python to avoid Mamba conflicts
    export UV_PYTHON_PREFERENCE=only-managed
    if [[ ! -f "pyproject.toml" || $_force -eq 1 ]]; then
        uv init "$_type" --python "$_py_version"
    else
        echo -e "\e[90m   Skipping uv init (pyproject.toml exists).\e[0m"
    fi

    # ─── Step 2b: Ensure proper directory structure ───────────────────────────
    mkdir -p "src/$PACKAGE_NAME" tests
    touch "src/$PACKAGE_NAME/__init__.py"
    touch "tests/__init__.py" "tests/conftest.py" "tests/test_placeholder.py"

    if [[ "$_type" == "--app" ]]; then
        [[ ! -f "src/$PACKAGE_NAME/main.py" ]] && touch "src/$PACKAGE_NAME/main.py"
    else
        touch "src/$PACKAGE_NAME/py.typed"  # PEP 561 marker
    fi

    rm -f hello.py

    # Add sentinel comment to version line for safe bump-my-version matching
    if grep -q '^version = "0\.1\.0"$' pyproject.toml 2>/dev/null; then
        sed -i 's/^version = "0\.1\.0"$/version = "0.1.0"  # project-version/' pyproject.toml
    fi

    # ─── Step 3: Add dev dependencies ─────────────────────────────────────────
    uv add --dev ruff pytest pytest-cov basedpyright colorlog bump-my-version pre-commit pip-audit

    # ─── Step 4: VS Code configuration ────────────────────────────────────────
    mkdir -p .vscode

    if _write_if_missing ".vscode/settings.json"; then
cat > .vscode/settings.json << 'VSCODE_EOF'
{
    "python.defaultInterpreterPath": ".venv/bin/python",
    // Disable Pylance/Microsoft Python type checking — basedpyright is the single
    // source of truth for this project (see `just typecheck`, CI and pyproject.toml).
    // Having both enabled produces duplicate, often conflicting diagnostics.
    "python.analysis.typeCheckingMode": "off",
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.codeActionsOnSave": {
        "source.fixAll.ruff": "always",
        "source.organizeImports.ruff": "always"
    },
    "python.testing.pytestEnabled": true,
    "python.testing.pytestArgs": [
        "src",
        "tests"
    ],
    "python.terminal.activateEnvironment": true
}
VSCODE_EOF
    fi

    if _write_if_missing ".vscode/launch.json"; then
cat > .vscode/launch.json << 'LAUNCH_EOF'
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python: Current File",
            "type": "python",
            "request": "launch",
            "program": "${file}",
            "console": "integratedTerminal",
            "justMyCode": false
        },
        {
            "name": "Python: Pytest",
            "type": "python",
            "request": "launch",
            "module": "pytest",
            "args": ["-s", "${file}"],
            "console": "integratedTerminal"
        }
    ]
}
LAUNCH_EOF
    fi

    # #26: Generate extensions.json for team/agent onboarding
    if _write_if_missing ".vscode/extensions.json"; then
cat > .vscode/extensions.json << 'EXTENSIONS_EOF'
{
    "recommendations": [
        "charliermarsh.ruff",
        "detachhead.basedpyright",
        "tamasfe.even-better-toml"
    ]
}
EXTENSIONS_EOF
    fi

    # ─── Step 5: pyproject.toml tool config ───────────────────────────────────
    # Idempotent: only append if sentinel section is missing
    if ! grep -q "tool.bumpversion" pyproject.toml 2>/dev/null; then
        cat >> pyproject.toml << TOOLS_EOF

[tool.ruff]
target-version = "py${_py_version//./}"
line-length = 120

[tool.ruff.lint]
select = ["E", "F", "W", "I", "N", "D", "UP", "B", "SIM", "RUF"]

[tool.ruff.lint.pydocstyle]
convention = "google"

[tool.basedpyright]
pythonVersion = "${_py_version}"
typeCheckingMode = "strict"
venvPath = "."
venv = ".venv"

[tool.pytest.ini_options]
testpaths = ["tests"]
pythonpath = ["src"]
addopts = "-ra -q"

[tool.bumpversion]
current_version = "0.1.0"
commit = true
tag = true
tag_name = "v{new_version}"
message = "chore: bump version from {current_version} to {new_version}"

[[tool.bumpversion.files]]
filename = "pyproject.toml"
search = 'version = "{current_version}"  # project-version'
replace = 'version = "{new_version}"  # project-version'

[[tool.bumpversion.files]]
filename = "src/${PACKAGE_NAME}/__init__.py"
search = '__version__ = "{current_version}"'
replace = '__version__ = "{new_version}"'
TOOLS_EOF

        # Write __version__ into __init__.py so bumpversion can find it
        if ! grep -q '__version__' "src/$PACKAGE_NAME/__init__.py" 2>/dev/null; then
            printf '__version__ = "0.1.0"\n' >> "src/$PACKAGE_NAME/__init__.py"
        fi
    elif [[ $_force -eq 1 ]]; then
        echo -e "\e[33m   Note: pyproject.toml tool config already present; --force does not regenerate tool config.\e[0m"
        echo -e "\e[33m   Reason: user customization in [tool.*] sections must be preserved. Edit manually if needed.\e[0m"
    fi

    # ─── Step 6: direnv setup ─────────────────────────────────────────────────
    if _write_if_missing ".envrc"; then
cat > .envrc << 'ENVRC_EOF'
# Deactivate any active non-base Conda environment to prevent variable leakage
if [[ -n "$CONDA_DEFAULT_ENV" && "$CONDA_DEFAULT_ENV" != "base" ]]; then
    conda deactivate 2>/dev/null || true
fi
watch_file uv.lock
layout uv  # uses layout_uv() from ~/.config/direnv/direnvrc
ENVRC_EOF
    fi
    direnv allow 2>/dev/null || true

    # ─── Step 7: Git + .gitignore ─────────────────────────────────────────────
    if [[ ! -d ".git" ]]; then
        git init
    fi

    if _write_if_missing ".gitignore"; then
        # Fetch gitignore from gitignore.io with local fallback for offline/bootstrap use
        if ! curl -fsSL -o .gitignore "https://www.toptal.com/developers/gitignore/api/python,linux,vscode"; then
            cat > .gitignore << 'GITIGNORE_BASE_EOF'
# Fallback .gitignore generated by Luxurious Python Stack
__pycache__/
*.py[cod]
*.so
.Python
.venv/
.env
.direnv/
.pytest_cache/
.ruff_cache/
.mypy_cache/
.coverage
htmlcov/
dist/
build/
*.egg-info/
.vscode/
GITIGNORE_BASE_EOF
        fi

        # Append Luxurious Python Stack additions
        cat >> .gitignore << 'GITIGNORE_EOF'

# Added by 'Luxurious Python Stack'
# volatile, agent-generated data
SESSION.md
JOURNAL.md
# MkDocs build output (library projects)
site/
# freestyle: here you can put whatever you want
ignore/
ign/
ignored/
ignored.txt
# end of 'Luxurious Python Stack'

# Allow shared VS Code settings (override any .vscode/ ignore above)
!.vscode/settings.json
!.vscode/launch.json
!.vscode/extensions.json
GITIGNORE_EOF
    fi

    # ─── Step 8: Justfile ─────────────────────────────────────────────────────
    if _write_if_missing "Justfile"; then
cat > Justfile << 'JUST_COMMON_EOF'
set shell := ["bash", "-uc"]

# Run tests with coverage report
test:
    uv run pytest --cov=src --cov-report=term-missing

# Run linters and type checker (find errors)
lint:
    uv run ruff check .
    uv run ruff format --check .
    uv run basedpyright

# Type check only
typecheck:
    uv run basedpyright

# Full local quality gate (lint + typecheck + tests)
check:
    uv run ruff check .
    uv run ruff format --check .
    uv run basedpyright
    uv run pytest --cov=src --cov-report=term-missing

# Fix linting issues
fix:
    uv run ruff check --fix .
    uv run ruff format .

# Audit dependencies for known security vulnerabilities.
# Runs pip-audit against the project .venv so the audit actually sees your locked deps.
# Requires `pip-audit` to be declared as a dev-dependency in pyproject.toml.
audit:
    uv run pip-audit

# Bump version — requires a clean working tree (patch | minor | major)
bump part="patch":
    #!/usr/bin/env bash
    if [ -n "$(git status --porcelain)" ]; then
        echo "Error: Working tree is dirty." >&2
        exit 1
    fi
    uv run bump-my-version bump {{part}}
JUST_COMMON_EOF

        # Append run recipe only for app projects
        if [[ "$_type" == "--app" ]]; then
cat >> Justfile << 'JUST_APP_EOF'

# Run the project
run:
    #!/usr/bin/env bash
    uv run python "src/$(basename "$PWD" | tr '-' '_')/main.py"
JUST_APP_EOF
        fi
    fi

    # ─── Step 8b: GitHub Actions CI/CD workflows ──────────────────────────────
    mkdir -p .github/workflows

    if _write_if_missing ".github/workflows/ci.yml"; then
cat > .github/workflows/ci.yml << 'CI_EOF'
name: CI
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v4
      - uses: extractions/setup-just@v2   # just is not bundled in GitHub runners
      - run: uv sync --dev
      - run: just check
      - run: uv run pip-audit   # security: check for known vulnerabilities (uses project .venv)
CI_EOF
    fi

    if _write_if_missing ".github/workflows/release.yml"; then
cat > .github/workflows/release.yml << 'RELEASE_EOF'
name: Release
on:
  push:
    tags: ["v*"]
jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      id-token: write   # required for PyPI Trusted Publishing (OIDC)
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v4
      - run: uv build
      - run: uv publish   # OIDC — configure a PyPI Trusted Publisher for this repo
      # Fallback (token-based, only if Trusted Publishing is not configured):
      # - run: uv publish
      #   env:
      #     UV_PUBLISH_TOKEN: ${{ secrets.PYPI_TOKEN }}
RELEASE_EOF
    fi

    # ─── Step 8c: Generate AGENTS.md from blueprint ───────────────────────────
    # _LUXUS_SCRIPT_DIR is set at source time and resolves symlinked shlib installations.
    local _BLUEPRINT="${_LUXUS_SCRIPT_DIR}/skills/luxuspythonstack/references/blueprint-AGENTS.md"
    if _write_if_missing "AGENTS.md"; then
        if [[ -f "$_BLUEPRINT" ]]; then
            sed -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
                -e "s/{{PACKAGE_NAME}}/$PACKAGE_NAME/g" \
                "$_BLUEPRINT" > AGENTS.md
            echo -e "\e[34m   Generated AGENTS.md from blueprint.\e[0m"
        else
            echo -e "\e[33m   Warning: blueprint-AGENTS.md not found, skipping AGENTS.md generation.\e[0m"
        fi
    fi

    # ─── Step 8d: Generate SESSION.md ─────────────────────────────────────────
    if _write_if_missing "SESSION.md"; then
cat > SESSION.md << 'SESSION_EOF'
Summary of the last session. Will be overwritten by every session.
SESSION_EOF
        echo -e "\e[34m   Generated SESSION.md.\e[0m"
    fi

    # ─── Step 8e: Generate JOURNAL.md ─────────────────────────────────────────
    if _write_if_missing "JOURNAL.md"; then
cat > JOURNAL.md << 'JOURNAL_EOF'
session history: all past sessions are appended here (last session at the end of the file)
JOURNAL_EOF
        echo -e "\e[34m   Generated JOURNAL.md.\e[0m"
    fi

    # ─── Step 8f: Generate README.md ──────────────────────────────────────────
    if _write_if_missing "README.md"; then
cat > README.md << README_EOF
# ${PROJECT_NAME}

## Getting Started

\`\`\`bash
uv sync
just check
\`\`\`

## Development

\`\`\`bash
just test       # run tests
just lint       # lint + type check
just fix        # auto-fix lint issues
just check      # full quality gate
\`\`\`

## Release

\`\`\`bash
just bump patch   # 0.1.0 → 0.1.1
git push origin main --tags
\`\`\`

See [AGENTS.md](AGENTS.md) for AI agent guidelines.
README_EOF
    fi

    # ─── Step 8e: .editorconfig ───────────────────────────────────────────────
    if _write_if_missing ".editorconfig"; then
cat > .editorconfig << 'EDITORCONFIG_EOF'
root = true

[*]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.md]
trim_trailing_whitespace = false

[*.{yml,yaml,toml,json}]
indent_size = 2

[Makefile]
indent_style = tab
EDITORCONFIG_EOF
    fi

    # ─── Step 8f: CONTRIBUTING.md ─────────────────────────────────────────────
    if _write_if_missing "CONTRIBUTING.md"; then
cat > CONTRIBUTING.md << CONTRIBUTING_EOF
# Contributing to ${PROJECT_NAME}

## Development Setup

\`\`\`bash
git clone <repo-url>
cd ${PROJECT_NAME}
direnv allow      # auto-activates .venv (or run: source .venv/bin/activate)
uv sync           # install all dependencies
\`\`\`

## Workflow

1. Create a feature branch: \`git checkout -b feature/my-feature\`
2. Make your changes
3. Run the quality gate: \`just check\`
4. Commit (pre-commit hooks run automatically): \`git add -A && git commit -m "feat: ..."\`
5. Push and open a pull request

## Quality Gate

\`\`\`bash
just lint         # ruff + basedpyright
just typecheck    # type checking only
just test         # pytest with coverage
just check        # full gate (lint + typecheck + tests)
just fix          # auto-fix formatting and lint issues
\`\`\`

## Conventions

- **Python version:** ${_py_version}
- **Typing:** Strict — all public functions must have type annotations
- **Docstrings:** Google style
- **Imports:** Sorted by ruff (isort-compatible)
- **Line length:** 120 characters

## Versioning

Never edit version numbers manually. Use:

\`\`\`bash
just bump patch   # bugfix: 0.1.0 → 0.1.1
just bump minor   # feature: 0.1.1 → 0.2.0
just bump major   # breaking: 0.2.0 → 1.0.0
\`\`\`

See [AGENTS.md](AGENTS.md) for AI agent guidelines.
CONTRIBUTING_EOF
    fi

    # ─── Step 8g: LICENSE file ────────────────────────────────────────────────
    if _write_if_missing "LICENSE"; then
        local _current_year
        _current_year="$(date +%Y)"
cat > LICENSE << LICENSE_EOF
MIT License

Copyright (c) ${_current_year} $(git config user.name 2>/dev/null || echo "Project Author")

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
LICENSE_EOF
    fi

    # ─── Step 9: pre-commit setup ─────────────────────────────────────────────
    if _write_if_missing ".pre-commit-config.yaml"; then
cat > .pre-commit-config.yaml << 'PRECOMMIT_EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-toml
  - repo: local
    hooks:
      - id: ruff-check
        name: ruff check
        entry: uv run ruff check --force-exclude
        language: system
        types_or: [python, pyi]
      - id: ruff-format
        name: ruff format
        entry: uv run ruff format --force-exclude
        language: system
        types_or: [python, pyi]
# Note: basedpyright runs in `just check` and CI, not as a pre-commit hook.
# Full-codebase type checking on every commit is too slow for interactive work.
PRECOMMIT_EOF
    fi

    # ─── Step 9b: MkDocs documentation (library projects only) ───────────────
    if [[ "$_type" == "--lib" ]]; then
        uv add --dev "mkdocs-material" "mkdocstrings[python]" 2>/dev/null || true

        if _write_if_missing "mkdocs.yml"; then
cat > mkdocs.yml << MKDOCS_EOF
site_name: ${PROJECT_NAME}
site_description: Documentation for ${PROJECT_NAME}
repo_url: https://github.com/YOUR_ORG/${PROJECT_NAME}

theme:
  name: material
  features:
    - navigation.tabs
    - navigation.sections
    - toc.integrate
    - search.suggest

plugins:
  - search
  - mkdocstrings:
      handlers:
        python:
          options:
            docstring_style: google
            show_source: true
            show_root_heading: true

nav:
  - Home: index.md
  - API Reference: api.md
MKDOCS_EOF
        fi

        mkdir -p docs
        if _write_if_missing "docs/index.md"; then
cat > docs/index.md << DOCS_INDEX_EOF
# ${PROJECT_NAME}

## Getting Started

\`\`\`bash
uv sync
just check
\`\`\`

## Installation

\`\`\`bash
pip install ${PROJECT_NAME}
\`\`\`

## Quick Start

\`\`\`python
import ${PACKAGE_NAME}
\`\`\`
DOCS_INDEX_EOF
        fi

        if _write_if_missing "docs/api.md"; then
cat > docs/api.md << DOCS_API_EOF
# API Reference

::: ${PACKAGE_NAME}
DOCS_API_EOF
        fi

        # Add docs recipe to Justfile (idempotent: only append if not present)
        if ! grep -q "^docs:" Justfile 2>/dev/null; then
cat >> Justfile << 'JUST_DOCS_EOF'

# Build documentation
docs:
    uv run mkdocs build

# Serve documentation locally (with live reload)
docs-serve:
    uv run mkdocs serve
JUST_DOCS_EOF
        fi

        echo -e "\e[34m   MkDocs documentation scaffolded (docs/, mkdocs.yml).\e[0m"
    fi

    # ─── Step 10: Final sync & install hooks ──────────────────────────────────
    uv sync
    uv run pre-commit install

    echo ""
    echo -e "\e[32m✨ Success! Project '${PROJECT_NAME}' is ready.\e[0m"
    echo ""
    echo "  Next steps:"
    echo "  1. direnv allow   (if not yet activated)"
    if [[ "$_type" == "--app" ]]; then
        echo "  2. Start coding in src/${PACKAGE_NAME}/"
        echo "  3. Run the app with: just run"
        echo "  4. Run tests with:   just test"
        echo "  5. Lint with:        just lint"
        echo "  6. Auto-fix:         just fix"
        echo "  7. Full gate:        just check"
    else
        echo "  2. Start coding in src/${PACKAGE_NAME}/"
        echo "  3. Run tests with: just test"
        echo "  4. Lint with:      just lint"
        echo "  5. Auto-fix:       just fix"
        echo "  6. Full gate:      just check"
    fi
    echo ""
    echo "  To release:"
    echo "  just bump patch"
    echo "  git push origin main --tags"

    unset -f _write_if_missing
}





# ─── jupyter-launcher ─────────────────────────────────────────────────────────
# Flexible Jupyter Lab launcher with optional Colab integration and port selection.
#
# Usage: jupyter-launcher [-n] [-c] [-p PORT] [folder]
#
#   -n          Tokenless mode: disables password/token authentication.
#               Useful for local development or when Google Colab should connect
#               without a token.
#
#   -c          Colab mode: adds the Google Colab CORS/XSRF arguments so that
#               colab.research.google.com can connect to this local server.
#               Can be combined with -n (token is then also disabled).
#
#   -p PORT     Use an alternative port instead of the default 8888.
#               Example: jupyter-launcher -p 9999
#
#   folder      Optional path to use as the notebook directory (--notebook-dir).
#               Use '.' to refer to the current working directory.
#               If omitted, ~/labor is used as the default.
#
# Examples:
#   jupyter-launcher                     # default: port 8888, ~/labor, token required
#   jupyter-launcher -n                  # tokenless, ~/labor
#   jupyter-launcher -c                  # Colab-compatible, ~/labor, token required
#   jupyter-launcher -n -c              # tokenless + Colab-compatible, ~/labor
#   jupyter-launcher -n -c .            # tokenless + Colab, current directory
#   jupyter-launcher -p 9999 myproject  # custom port, ./myproject as notebook-dir
#   jupyter-launcher -n -c -p 9999 .   # all options combined
#
# Personal alias suggestion: alias jl='jupyter-launcher -n -c'
jupyter-launcher() {

    # ─── FLAG ARGUMENT DOCUMENTATION ──────────────────────────────────────────
    # --no-browser
    #     Prevents Jupyter from automatically opening a browser window on start.
    #
    # --ip=127.0.0.1
    #     Binds the server strictly to localhost (security: not reachable from LAN).
    #
    # --port=PORT
    #     Sets the port for the local Jupyter instance (default: 8888).
    #
    # --ServerApp.port_retries=0
    #     Aborts immediately if the chosen port is already in use, instead of
    #     silently falling back to the next port (e.g. 8889). This prevents
    #     accidental multi-instance confusion.
    #
    # --notebook-dir=PATH
    #     Sets the root directory shown in the Jupyter file browser.
    #
    # ─── BUGFIX: FILE-ID ERRORS AND INFINITE LOOPS ────────────────────────────
    # --YDocExtension.disable_rtc=True
    #     Disables Real-Time Collaboration (RTC). Without this, JupyterLab enters
    #     a 404 loop trying to open the "globalAwareness" room, which blocks the
    #     server. Safe to disable when collaboration is not needed.
    #     NOTE: To prevent WebSocket crashes with Google Colab (TypeError on strings),
    #     the underlying server extensions (jupyter_server_documents and 
    #     jupyter_server_ydoc) are globally disabled via ~/.jupyter/jupyter_server_config.json
    #     during the initial Mamba system setup.
    #
    # --FileIdManager.file_id_manager_class=jupyter_server.fileid.manager.ArbitraryFileIdManager
    #     Fixes the recurring "File ID error". By default Jupyter uses a local
    #     SQLite database for file IDs which frequently gets corrupted or loses
    #     track of paths. The ArbitraryFileIdManager keeps IDs in memory only -
    #     files can be opened again without DB corruption issues.
    #
    # ─── GOOGLE COLAB INTEGRATION (only when -c is set) ───────────────────────
    # --ServerApp.allow_origin='https://colab.research.google.com'
    #     Allows Colab to access this local server via CORS.
    #
    # --ServerApp.allow_remote_access=True
    #     Required for any external origin to be permitted at all.
    #
    # --ServerApp.disable_check_xsrf=True
    #     Prevents the server from treating Colab requests as malicious
    #     cross-site request forgery (XSRF) attacks.
    #
    # ─── TOKENLESS MODE (only when -n is set) ─────────────────────────────────
    # --ServerApp.token=''
    #     Disables the password/token prompt entirely.
    #
    # --ServerApp.allow_credentials=True
    #     Required when Colab (or any client) needs to connect without a token.
    # ──────────────────────────────────────────────────────────────────────────

    # ── Default values for all configurable options ───────────────────────────
    local _jl_tokenless=0      # -n flag: 1 = disable token authentication
    local _jl_colab=0          # -c flag: 1 = add Colab CORS/XSRF arguments
    local _jl_port="8888"      # -p PORT: port number (default 8888)
    local _jl_folder=""        # positional: notebook-dir path (empty = use default)

    # ── Parse optional flags with getopts ─────────────────────────────────────
    # getopts processes flags one at a time; OPTIND tracks the position so we
    # can shift to the remaining positional argument (the optional folder) afterward.
    local OPTIND=1
    local _jl_opt
    while getopts ":ncp:" _jl_opt; do
        case "$_jl_opt" in
            n)
                # Tokenless mode: no password/token required
                _jl_tokenless=1
                ;;
            c)
                # Colab mode: enable Google Colab CORS/XSRF arguments
                _jl_colab=1
                ;;
            p)
                # Custom port: OPTARG holds the value that follows -p
                _jl_port="$OPTARG"
                ;;
            :)
                # A flag that requires an argument was given without one (e.g. -p with no number)
                echo "jupyter-launcher: option -${OPTARG} requires an argument." >&2
                return 1
                ;;
            \?)
                # An unknown flag was passed; print usage hint and abort
                echo "jupyter-launcher: unknown option -${OPTARG}." >&2
                echo "Usage: jupyter-launcher [-n] [-c] [-p PORT] [folder]" >&2
                return 1
                ;;
        esac
    done

    # Shift past the flags so that "$1" now refers to the optional folder argument
    shift $(( OPTIND - 1 ))

    # ── Resolve the notebook directory ────────────────────────────────────────
    if [[ $# -ge 1 ]]; then
        # A folder argument was provided. '.' is explicitly valid and resolves to
        # the current working directory via pwd.
        if [[ "$1" == "." ]]; then
            _jl_folder="$(pwd)"
        else
            # Expand to an absolute path so Jupyter always sees a clean path,
            # regardless of how the user typed it (relative or absolute).
            _jl_folder="$(realpath -m "$1")"
        fi
        # Create the directory if it does not exist yet, so Jupyter does not error.
        mkdir -p "$_jl_folder"
    else
        # No folder argument: fall back to the standard workspace directory.
        _jl_folder="$HOME/labor"
        mkdir -p "$_jl_folder"
    fi

    # ── Build the argument list incrementally ─────────────────────────────────
    # Using an array avoids quoting pitfalls and makes conditional flag injection
    # clean and readable.
    local -a _jl_args=(
        --no-browser
        --ip=127.0.0.1
        "--port=${_jl_port}"
        --ServerApp.port_retries=0
        "--notebook-dir=${_jl_folder}"
        # Disable real-time collaboration to prevent the globalAwareness 404 loop
        --YDocExtension.disable_rtc=True
        # Use in-memory file ID manager to avoid SQLite corruption errors
        --FileIdManager.file_id_manager_class=jupyter_server.fileid.manager.ArbitraryFileIdManager
    )

    # ── Conditionally append tokenless-mode arguments ─────────────────────────
    if [[ $_jl_tokenless -eq 1 ]]; then
        _jl_args+=(
            --ServerApp.token=''
            # allow_credentials is required for credential-bearing requests (e.g. from Colab)
            --ServerApp.allow_credentials=True
        )
    fi

    # ── Conditionally append Colab-integration arguments ──────────────────────
    if [[ $_jl_colab -eq 1 ]]; then
        _jl_args+=(
            # Grant Colab cross-origin access to this local server
            "--ServerApp.allow_origin=https://colab.research.google.com"
            --ServerApp.allow_remote_access=True
            # Disable XSRF check so Colab requests are not rejected as attacks
            --ServerApp.disable_check_xsrf=True
        )
    fi

    # ── Print a summary so the user knows exactly what will start ─────────────
    echo "Starting Jupyter Lab:"
    echo "  notebook-dir : $_jl_folder"
    echo "  port         : $_jl_port"
    echo "  tokenless    : $([ $_jl_tokenless -eq 1 ] && echo yes || echo no)"
    echo "  colab mode   : $([ $_jl_colab    -eq 1 ] && echo yes || echo no)"
    echo ""

    # ─── Launch Jupyter with the assembled argument list ───────────────────────
    jupyter lab "${_jl_args[@]}"
}

# Standard alias for quick access (tokenless + Colab mode, default directory)
alias jl='jupyter-launcher -n -c'