# Test Python (uv, mamba, direnv)

## [auto] Python base

* check if python3 is installed (`command -v python3`)

## [auto] uv

* check if uv is installed (`command -v uv`)
* check if ~/.local/bin/uv exists or is in PATH
* check if uv tools are installed: ruff, bump-my-version, basedpyright, nbstripout (`uv tool list`)

## [auto] direnv

* check if direnv is installed (`command -v direnv`)
* check if ~/.config/direnv/direnvrc exists and contains layout_uv function
* check if direnv hook is in .zshrc (at the end)

## [auto] Mamba

* check if ~/miniforge3/ exists
* check if mamba is available (`command -v mamba`)
* check if ~/.shlib/shlibs/41-python-config.sh exists and contains: UV_PYTHON_PREFERENCE, MAMBA_ROOT_PREFIX, mamba shell hook, act function, allowuv alias
* check if DIRENV_LOG_FORMAT is set to empty (in shlib)

## [auto] Jupyter config

* check if ~/.jupyter/jupyter_server_config.json exists and disables RTC extensions (jupyter_server_documents and jupyter_server_ydoc set to false)

## [hitl] Functional check

* run `uv --version` and confirm it works
* run `mamba --version` and confirm it works
* run `act` without arguments and confirm it shows current environment or switches to base
* create a test directory, run `allowuv`, and confirm .envrc is created with `layout uv`

## [hitl] Data Science environment (optional)

* if a ds environment exists: run `mamba activate dsXX` (replace XX) and confirm it activates
* run `python -c "import torch; print(torch.cuda.is_available())"` and confirm CUDA is available (on GPU machines)
