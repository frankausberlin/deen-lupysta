### 🐍 Python (uv, mamba, direnv)

```shell
# Python 3 base (pipx only if you need a fallback for tools that don't play nice with `uv tool`)
sudo nala install -y python3
# Optional fallback: sudo nala install -y pipx

# UV (The lightning-fast Rust-based manager)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Make uv immediately available in the current terminal (without restart)
source "$HOME/.local/bin/env"

# Base equipment (uv tool = pipx on steroids)
uv tool install ruff && uv tool install bump-my-version && uv tool install basedpyright

# 'just' and 'direnv' are already installed via Homebrew in section 1.2 (Base Tools).
# Here we only create the direnv layout for uv.
mkdir -p ~/.config/direnv && cat << 'EOF' > ~/.config/direnv/direnvrc
layout_uv() {
    # If no environment exists yet, uv creates one in a flash.
    [ ! -d ".venv" ] && uv venv
    # Tell direnv where the bin directory is located.
    export VIRTUAL_ENV="$(pwd)/.venv" && PATH_add "$VIRTUAL_ENV/bin"
    # UV also knows this.
    export UV_PROJECT_ENVIRONMENT="$VIRTUAL_ENV"
}
EOF

# mamba
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"

# Batch mode (-b): Installs silently without interactive queries to ~/miniforge3
bash Miniforge3-$(uname)-$(uname -m).sh -b -p "$HOME/miniforge3"

# Register UV safety net (instead of `conda init zsh` we put Conda and UV directly into the shlib)
cat << 'EOF' > ~/.shlib/shlibs/40-python-config.sh
# --- UV ---
# Strictly use own/managed Python versions (Protects System-Python!)
export UV_PYTHON_PREFERENCE=only-managed
# make uv available in the shell
. "$HOME/.local/bin/env"

# --- direnv ---
# Suppress direnv log output to avoid p10k instant-prompt interference
export DIRENV_LOG_FORMAT=""

# --- Mamba Initialization ---
# Mamba 2.0+ requires this variable before initialization
export MAMBA_ROOT_PREFIX="$HOME/miniforge3"
# Here we explicitly load the 'mamba' hook, not 'conda'
__mamba_setup="$('$HOME/miniforge3/bin/mamba' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    # Miniforge also conveniently creates a mamba.sh
    if [ -f "$HOME/miniforge3/etc/profile.d/mamba.sh" ]; then
        . "$HOME/miniforge3/etc/profile.d/mamba.sh"
    else
        export PATH="$HOME/miniforge3/bin:$PATH"
    fi
fi
unset __mamba_setup

# --- Default Environment Activation ---
# Only activate a Mamba env if no project-level .envrc is present in the CWD.
# In project directories direnv supersedes Mamba anyway — skipping the activation
# keeps shell startup fast.
if [ ! -f "$PWD/.envrc" ]; then
    mamba activate $([[ -f ~/.startenv ]] && echo "$(< ~/.startenv)" || echo base)
fi

# startenv function
act() { [ "$#" -ne 0 ] && echo $1 > ~/.startenv && mamba activate $1; }

# Creates an environment in a folder if it doesn't already exist and places it under the management of direnv.
alias allowuv='echo "layout uv" > .envrc && direnv allow'
EOF

# Clean up installation file
rm Miniforge3-*.sh

# Reload shell so that Conda and UV are activated
exec zsh
```

#### Example Data Science Mamba Environment

* ⚠️ Using ipywidgets 7.7.1 for colab runtime compatibility.

```shell
#                     (re)create a data science environment with all the goodies and activate it
# _________________________________________________________________________________________________________________________________
py=3.12 && ENV_NAME="ds${py: -2}" && mamba deactivate && mamba remove -y -n $ENV_NAME --all 2>/dev/null # python 3.XY --> 'dsXY'
mamba   create -y -n $ENV_NAME python=$py google-colab cuda-toolkit && mamba activate $ENV_NAME # testet with python 3.11/12/13
uv pip  install vllm # seperate installation works -> python voodoo
uv pip  install torch torchvision scikit-learn jax jupyterlab jupytext jupyter_http_over_ws jupyter-ai jupyterlab-github fastai\
        numba langchain langchain-openai langchain-ollama transformers evaluate accelerate nltk tf-keras hrid huggingface-hub\
        rouge_score datasets unstructured opencv-python soundfile nbdev llama-index 'tensorflow[and-cuda]' setuptools wheel mcp\
        graphviz xeus-python PyPDF2 ipywidgets==7.7.1
jupyter labextension enable jupyter_http_over_ws && echo $ENV_NAME > ~/.startenv
python  -m ipykernel install --user --name $ENV_NAME --display-name $ENV_NAME
# _________________________________________________________________________________________________________________________________
# _______________________________________use_'act'_instead_of_'mamba_activate'_____________________________________________________
# mamba activate $(cat ~/.startenv) # insert in your shell rc file
# act() { [ "$#" -ne 0 ] && echo $1 > .startenv && mamba activate $1; } # switch environment and remember
```

Important notes on the Mamba level:

- It doesn't necessarily have to be data science. Any domain is possible — this just happens to be mine.
- It's generally not recommended to use `uv` in a Mamba environment, as packages installed this way are not under Mamba's control. This can lead to conflicts when updating.
- I use the data science environment in a way that makes this problem irrelevant. I'm constantly installing new libraries, deleting old ones, and experimenting. Just as frequently (sometimes twice a day), I completely wipe the environment and reinstall it.
- That's why I use `uv`; it's so incredibly fast.
- **The rule is: no updates, just delete and recreate.** Only in this way can the dependency conflicts eliminated.
