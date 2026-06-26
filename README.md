  ***(🚧 WIP)* <font color=red>Actually, the only reason I have this thing public at the moment is because I often use git clone in different systems for testing reasons, saving me the trouble of logging into github every time using 2-step authentication. But at the moment the project is still far from release status and should not be unleashed on humanity.</font>**

<table><tr><td align=right><img src="https://lh3.googleusercontent.com/d/1jn-jtlNEAjJ771Ziu4P92YlJX8yb41q9" width=1000><font size=-2><br>for agents, for humans, for the hole damned world</td></tr>
<tr align=center><td>

| | | | | |
| :---: | :---: | :---: | :---: | :---: |
| 💎 **Luxurious**<br>**Python Stack** | | | | |
| 💻 Global<br>System | 🔬 Mamba<br>Jupyter | 🗂️ Projects<br>pyproject.toml | 🏢 CI/CD<br>Justfile | 🤖 AI Agents<br>SKILL.md |
| **🧠 AI Stack** | | | | |
| 🦙 Ollama, Agents<br>Odysseus | 🔌 MCPHub<br>Open WebUI | 🎓 Hermes<br>Lionheart | 🛡️ LiteLLM<br>Vibe-Kanban | ☁️ vast.ai<br>LocalAI, OpenLIT |
| **🛠️ Developer**<br>**Environment** | | | | |
| 🐧 Ubuntu<br>Base-System | 🛡️ Network<br>Security | 📦 Docker<br>Cuda | 👾 Git, Code<br>SearXNG | 🌎 Eco<br>Systems |
| **🧱 Policies / ZShell**<br>**Shlib System / Nala** | | | | |

*I'm constantly installing and configuring Ubuntu on my laptop, PC, and Pi. However, since I'm just a simple programmer and not a Lion (Linux Operator Nerd), I've started storing the most important things in Colab notebooks so I can easily access everything via copy and paste.*

*That escalated a little...*</td></tr></table>

# 📚 The AI-flavored Developer Environment & Luxurious Python Stack 

consists of the installation instructions for the developer environment with an AI stack that integrates seamlessly into the Luxurious Python Stack. Python is optional; it also works with other languages ​​(python happens to be my first choice but it could just as well e.g. give a node version of it: Deen Lunosta).
The instructions are intended for both humans and agents.

🚀 how to start:

* Get an overview of Deen Lupysta, preferably by reading the readme.
* In Chapter '6. Stage Concept' describes the installation process.
* I strongly recommend installing using agents as described there.
* Agents are instructed not to carry out any critical operations themselves but only to generate the commands (sudo ..) and then let you execute them (human-in-the-loop principle).
* If you follow the installation carefully and are not afraid to ask your agents something, you will gain a fundamental understanding of the system: “Learning by Installing”.

💥 some highlights:

* A collection of installation cheat sheets for agents and humans
* The Shell Library System (shlib) - simple but efficient
* Set up a secure Ubuntu AI developement system with the Concierge skill, monitored and maintained by the Lionheart skill
* Multi-level concept for Python development in the area of data science and classic CI/CD projects
* A comfortable data science mamba environment with cuda support for pytorch, tensorflow, numba and jax.
* Setting up an AI system with Rag and VAD supported real-time conversation based on Open WebUI
* The MCPHub self-hosts a toolbox for agents and Open WebUI
* Swarm and CI/CD ready luxus-python-stack skill for coding agents
* Setting up security concepts (guardrails) for heartbeat agents
* Routing strategies, resiliency and cost control for agent models with LiteLLM
* Manages software development of agent swarms using vibe-kanban
* Host and integrate LLMs yourself with LocalAI and VastAI, monitored by OpenLIT
* A [Stage Concept](#6.-🪜-Stage-Concept) for an agent-supported, incremental, and evaluable integration

👉 how it works:

* You just need to install OpenCode or another agent and use the Concierge skill (described 🟠 Stage 1: Onboarding). You do the rest together with Conrad, the concierge (Human-In-The-Loop).

* In the file MYDEENLUPYSTA.md there is a profile with the current configuration. It is created by the concierge during the installation and contains all relevant information for the subsystems set up (responsibilities, paths to configuration files, fundamental decisions such as omitting or adding a subsystem). It serves the user as a single point of reference and is the basis for Lionheart to maintain the system.

* The Lionheart skill is triggered by a heartbeat and reacts accordingly. Heartbeats:<br>
  - Daily Check (cron job)
  - Weekly analysis (cron job)
  - Guardrails webhook events (eg out-of-budget, common errors)
  - Events from other subsystems, freely configurable via concierge

* Finally, the luxury Python Stack skill is for software development agents who produce software in swarms and supports autonomous work and the human-in-the-loop process.

* We have clear responsibilities:<br>
  * the Concierge maintains MYDEENLUPYSTA.md, removes subsystem, adds new ones, sets up the desired system architecture and the desired heartbeats from subsystems. He also solves problems togehter with the user (human-in-the-loop) that lionheart found and documented (reco.sh)<br>
  *Lionheart runs the Linux system and Deen Lupysta, reads log files, cleans up, analyzes problems and creates the reco.sh. Lionheart works autonomously, its cron jobs (heartbeats) are managed by Conrad after consultation with the user.
  * The luxury Python stack skill is only relevant for the area of ​​software development.

***The repository here should in no way be seen as a strict guide. It's just one possible path among many, very much influenced by my preferences. Think of it as a box full of different blueprints that you can mix, match, and swap as you wish. I simply recommend making all adjustments with the concierge, this will avoid problems, eliminate complex configuration processes and ensure a clean integration.***

---

<table><tr><td><font size=+5>🚨</font></td><td><font color=red><b>Important note:</b></font>

Never run scripts or script snippets without carefully reviewing them.
* Sometimes parts of the scripts need to be replaced with your own data.
* Sometimes the scripts trigger a TUI dialog that expects input.
* The scripts are optimized for zsh. Keep this in mind.

**You must know exactly what you are doing and what you want to achieve.**<br>
**If you are unsure, ask Conrad.**
</td></tr></table>

---

# 1. 🐧 Developer Environment
## 1.1 📜 [Package Manager Policy](developer-environment/01-policies.md)
## 1.2 🧱 [Shlib System / ZSH I](developer-environment/02-zsh1-shlib.md)
## 1.3 🚀 [Base Tools, Libs & Co.](developer-environment/03-base-tools-libs.md)
## 1.4 🔒 [Network & security](developer-environment/04-net-security.md)
## 1.5 📦️ [Docker & CUDA Toolkit](developer-environment/05-docker-cuda.md)
## 1.6 🌐 [Git, Code & SearXng](developer-environment/06-git-code-searxng.md)
## 1.7 🧿 [ZSH II, Antidote & p10k](developer-environment/07-zsh2-antidote-p10k.md)
## 1.8 📋 [Shell Library deenlupysta.sh](scripts/deenlupysta.sh)

# 2. 🗺️ Ecosystems
## 2.1 🟢 [Node.js (fnm + pnpm)](developer-environment/01-nodejs.md)
## 2.2 🐍 [Python (uv, mamba, direnv)](developer-environment/02-python.md)
## 2.3 🦀 [Rust (rustup & cargo)](developer-environment/03-rust.md)
## 2.4 🐹 [Go (Go Toolchain)](developer-environment/04-go.md)
## 2.5 ☕ [Java (SDKMAN!)](developer-environment/05-java.md)
## 2.6 💎 [Ruby (rbenv & bundler)](developer-environment/06-ruby.md)

---

# 3. 🧠 AI Stack
## 3.1 🦙 [Ollama & Agents](ai-stack/01-ollama-agents.md)
## 3.2 🔌 [Mcphub & Open WebUI](ai-stack/02-mcphub-openwebui.md)
## 3.3 🎓 [Hermes & Lionheart](ai-stack/03-hermes-lion.md) *(🚧 WIP)*
## 3.4 🛡️ [LiteLLM & Vibe-Kanban](ai-stack/04-litellm-vibekanban.md) *(🚧 WIP)*
## 3.5 ☁️ [Vast.AI, LocalAI & OpenLIT](ai-stack/05-vastai-localai.md) *(🚧 WIP)*

---

# 4. 💎 Luxurious Python Stack
## 4.1 📚 [Stack Description](luxuspythonstack.md)
## 4.2 🤖 [Agent Guide Blueprint](skills/luxuspythonstack/references/blueprint-AGENTS.md)
## 4.3 👷 [Daily Commands Reference](skills/luxuspythonstack/references/daily-commands.md)
## 4.4 💓 [Cron Setup (Heartbeat)](skills/luxuspythonstack/references/cron-setup.md)
## 4.5 📜 [reco.sh Format Specification](skills/luxuspythonstack/references/reco-format.md)
## 4.6 ⛑️ [Health Checks](skills/luxuspythonstack/references/health-checks.md)
## 4.7 🏗️ [Skill - *luxuspythonstack/*](skills/luxuspythonstack/SKILL.md)
## 4.8 🔧 [Scripts - *luxuspythonstack.sh*](scripts/luxuspythonstack.sh)
## 4.9 📋 [Scripts - dsdash.ipynb](scripts/dsdash.ipynb)
---


# 5. 💡 Overview Responsibilities

## 5.1 🏗 Software Architecture

| **Software**<br>GitHub stars ⭐ June 26 | **Responsibility** |
| :--- | :--- |
| **[Ollama](https://github.com/ollama/ollama)**<br>173k ⭐ | Ollama is a simple inference engine and is used for<br>• Embedding & reranking models (e.g. `qwen3-embedding:0.6b`)<br>• OCR, vision and translation models (e.g. `translategemma`)<br>• Chat and agent models are unlikely to run on ollama. |
| **Agents**<br>[OpenCode](https://github.com/anomalyco/opencode) 169k ⭐<br>[Claude](https://github.com/anthropics/claude-code) 130k ⭐<br>[Kilo Code](https://github.com/Kilo-Org/kilocode) 20k ⭐ | Agents use tools, have skills, complete tasks and chat with humans or other agents<br>• Autonomous codebase manipulation & task execution<br>• System health monitoring & automated routines<br>• Human-in-the-Loop (HITL) coding assistance<br>• Autonomous programming, Swarm communication |
| **[Odysseus](https://github.com/pewdiepie-archdaemon/odysseus)**<br>73k ⭐ | The AI stack from YouTube legend Pewdiepie<br>• A simple chat harness with integrated web search<br>• Good cooperation with local models and convenient deep research function<br>• The auto-extract function automatically creates memories and skills<br>• Agents can compete against each other in compare mode. |
| **[MCPHub](https://github.com/samanhappy/mcphub)**<br>2.1k ⭐ | The MCPHub is the toolbox for agents or other harnesses<br>• Centralized Model Context Protocol proxy (User Service)<br>• Connects LLMs to local/web tools (SearXNG, Filesystem, Docker, etc.)<br>• Offers all common API formats (open api, html, sse).<br>• Allows you to create groups with a selection of servers and tools<br>• Easy to create your own prompts and resources (according to protocol standard) |
| **[OpenWebUI](https://github.com/open-webui/open-webui)**<br>140k ⭐ | Open WebUI is an extensible, feature-rich, and user-friendly self-hosted AI platform<br>• Primary graphical interface for Chat & RAG<br>• RAG system with configurable embedding and reranking model <br>• Configurable web crawler (e.g. Firecrawl)<br>• Realtime audio conversation with local models (ollama or localai)<br>• Offers the complete Deen Lupysta repo as a knowledge base. |
| **[Hermes](https://github.com/NousResearch/hermes-agent)**<br>178k ⭐ | The autonomous agent with heartbeat mechanism (cronjob, webhook)<br>• Use the Lionheart Skill to maintain the Deen Lupysta system and creates system diagnostics<br>• If action is required, the file ~/reco.sh is created<br>• No actions are taken, only the recommendation file is generated: ~/reco.sh<br>• Monitored by LiteLLM: Guardrails, fallback-models and cost control<br>• Communicates with the user via telegram, cli or desktop app |
| **[LiteLLM](https://github.com/BerriAI/litellm)**<br>49.1k ⭐ | OpenAI compatible Proxy Server (LLM Gateway) to call LLMs<br>• Manages external and local models<br>• Provides a unified interface for AI applications<br>• Track spend, set budgets per virtual key/user<br>• Secures LLM calls with Guardrails<br>• Reliability through model routing<br>• Routing strategies (e.g. use openrouter free until the quota is exhausted and then use kilo free) |
| **[VibeKanban](https://github.com/BloopAI/vibe-kanban)**<br>26.8k ⭐ | VibeKanban handles a kanban board and branches for autonomous agents<br>• Parallel orchestration lets multiple agents work in parallel or in chains (sequences).<br>• Git & project integration with branches for tasks<br>• Bidirectional MCP<br>&nbsp;&nbsp;&nbsp;&nbsp;- As a client, it passes tools (from mcphub or litellm) to the agents.<br>&nbsp;&nbsp;&nbsp;&nbsp;- As a server, it provides the Kanban board itself as an MCP resource<br>• Autonomous agents can independently create tasks or query the status of the board.<br><br>⚠️ **Sunsetting notice (April 2026):** The company bloop has shut down. The project continues as community-maintained open source (Apache-2.0). Remote services are limited; local-only architecture is the recommended deployment. Expect slower release cadence and self-hosted deployments. |
| **[LocalAI](https://github.com/mudler/LocalAI)**<br>46.6k ⭐ | LocalAI is a composable AI stack for running models locally and is used in two scenarios:<br><br>**1. Local**<br>• Only 'small things' are offered such as whispers, voice models and small fallback models<br><br>**2. Hosted**<br>• Uses powerful open weights models <br>• Manages multiple model instances to realize agent swarms<br>• Employs a persistence mechanic to handle host failures |
| **[OpenLIT](https://github.com/openlit/openlit)**<br>2.5k ⭐ | Open-source AI engineering platform<br>• Hardware-related system for managing and maintaining swarms<br>• LLM observability and metric monitoring<br>• GPU performance and error handling |
<br>

## 5.2 🏛️ Core Artefacts

### 5.1 📇 Rules and code

| Artefacts | Responsibility |
| :--- | :--- |
| **Deen Lupysta Repo** | • Knowledge base for agents and humans<br>• Integrated into the Open WebUI RAG to answer questions<br>• Allows easy adjustments to the system |
| **Shlib System** | • Modular, multi-device shell configuration<br>• `.zshrc` lock mechanism and integrity validation<br>• Dynamic environment variable loading via file exports |
| **Policies** | • Strict package manager guidelines (apt vs. brew vs. uv vs. pnpm)<br>• Consistent folder structures, routing rules and conflict prevention across system layers<br>• Strict instructions for agents and provision of skills |
| **Guardrails** | • Security boundaries for autonomous agent behavior<br>• Prevention of destructive or system-altering commands<br>• Enforcement of Human-in-the-Loop validation constraints |
| **Luxus Python Stack** | • 5-level environment isolation architecture<br>• Mamba / uv / direnv workflow definitions<br>• Agent session context management (`AGENTS.md`, `SESSION.md`)<br> • Luxury Python stack skill for efficient work in swarms and with humans|
| **luxuspythonstack.sh** | • Automated project scaffolding and setup (`pyinit`)<br>• Fast environment toggles and state saving (`act`)<br>• Configurable, token-aware Jupyter runtime launcher (`jupyter-launcher`) |
| **deenlupysta.sh** | • Path sanitization and deduplication (`repair_path`)<br>• Core system routines and alias management (`cw`, `suu`, `los`)<br>• Repository synchronization commands (`deensync`) |
| **dsdash.ipynb** | • Data Science utility snippets and interactive UI widgets<br>• CUDA hardware validation across PyTorch, TF, JAX, and Numba<br>• OpenRouter frontier model scraper and spec analyzer |

### 5.2 🎓 Skills

| Artefacts | Responsibility |
| :--- | :--- |
| **Concierge Skill** | • Maintains the MYDEENLUPYSTA.md, the central system reference<br>• Guides the user through the installation and configuration process<br>• Effective integration using setup matrix and stage concept |
| **MYDEENLUPYSTA.md** | • Describes the local Deen Lupysta system with all deviations from the reference installation from the repository.<br>• Created and maintained by an agent during setup.<br>• Creates backups of changed files and creates an instruction to undo the change (UNDO.md). |
| **Heartbeats** | • Events that trigger an agent to perform a specific task<br>• Cronjob events with a daily and a weekly check<br>• Application events are generated by subsystems, e.g. Budget, routing, guardrails, error handling ... |
| **Lionheart Skill** | • 4-Tier daily/weekly system health monitoring<br>• Telegram notification and status reporting<br>• Generation of executable, commented action templates (`reco.sh`) |
| **Luxus Python Stack Skill** | • 5-level environment isolation architecture<br>• Mamba / uv / direnv workflow definitions<br>• Agent session context management (`AGENTS.md`, `SESSION.md`)<br> • Luxury Python stack skill for efficient work in swarms and with humans|


# 6. 🪜 Stage Concept

One step after the next. Deen Lupysta is too large to install in one go. That's why I came up with a stage concept. In each stage, a part of Deen Lupysta is installed and configured and tested with practical use cases.

## 6.1 🟠 Stage 1: Onboarding

We install Nala, Git and an agent in advance to use the concierge skill. To do this we need to clone the deen-lupysta repo.

* Hermes (or any other agent with skill support)
```shell
# use nala instead of apt
sudo apt update && sudo apt install -y nala
sudo nala update && sudo nala upgrade

# install git and clone deen lupysta
sudo nala install git && mkdir -p ~/gits && cd ~/gits
git clone https://github.com/frankausberlin/deen-lupysta
mkdir -p ~/deenlupysta/backup && touch ~/deenlupysta/backup/UNDO.md
cp ~/gits/deen-lupysta/MYDEENLUPYSTA.md.example ~/deenlupysta

# Install Hermes 
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

# ⚠️ Note: you don't necessarily have to use Hermes, but if you use another agent, you should make sure that it also uses the skill. The skill is just a file and can also be used directly by transferring it using prompt.

# run hermes to setup your model provider
# then we can link the skill
ln -s ~/gits/deen-lupysta/skills/concierge ~/.hermes/skills/autonomous-ai-agents/concierge


# The next time you start hermes you will have access to the skill. Simply start your prompt with "Use your concierge skill".
```

## 6.2 🟡 Stage 2: Base System

* In this stage the Linux developer system is installed or aligned. 
* There are 5 setup steps to be carried out. 
* These are described in the respective markdown files and have their own agent guide.
* After each setup step, tests must be carried out by the user and the agent to ensure functionality.


### Step 1: 

Lies die datei developer-environment/01-policies.md. Diese Datei beinhaltet nur regeln und keine anweisungen.


### Step 2:

developer-environment/02-zsh1-shlib.md
developer-environment/03-base-tools-libs.md.

**Test:**<br>

* Test das Shlib-System<br>
  * 


### Step 3:

developer-environment/03-net-security.md
developer-environment/04-docker-cuda.md

### Step 4:

05-git-code-searxng.md
06-zsh-antidote-p10k.md



## 6.3 🟢 Stage 3: Ecosystems

07-nodejs.md   
08-python.md      
09-rust.md
10-go.md
11-java.md
12-ruby.md

## 6.4 🔵 Stage 4:

01-ollama-agents.md

## 6.5 🟣 Stage 5:

02-mcphub-openwebui.md

## 6.6 🟤 Stage 6:

03-hermes-lion.md

## 6.7 ⚫ Stage 7:

04-litellm-vibekanban.md

## 6.8 ⚪ Stage 8:

05-vastai-localai.md

## 6.9 🔴 Stage 9:

reference project for the luxus python stack for ~ 3 or 4 agents



