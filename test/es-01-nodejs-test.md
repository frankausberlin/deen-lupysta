# Test Node.js (fnm + pnpm)

## [auto] fnm

* check if fnm is installed (`command -v fnm`)
* check if ~/.local/share/fnm/ exists
* check if ~/.shlib/shlibs/40-nodejs-config.sh exists and contains FNM_PATH, fnm env, PNPM_HOME

## [auto] Node.js

* check if node is installed (`command -v node`)
* check if npm is installed (`command -v npm`)
* check if a default Node version is set (`fnm default` or check ~/.local/share/fnm/aliases/default/)
* check if persistent default bin exists (~/.local/share/fnm/aliases/default/bin/node)

## [auto] Corepack & pnpm

* check if corepack is installed (`command -v corepack`)
* check if pnpm is installed (`command -v pnpm`)
* check if npx is installed (`command -v npx`)
* check if PNPM_HOME is in PATH

## [auto] Shlib hygiene

* check no stale fnm_multishells paths in ~/.shlib/shlibs/ (`grep -R fnm_multishells ~/.shlib/shlibs`)
* check no copied full PATH snapshots in shlib files (`grep -R -E '^export PATH=([^"$]|"[^$]*")' ~/.shlib/shlibs`)

## [auto] Global tools

* check if kilocode is installed (`command -v kilocode`)
* check if pm2 is installed (`command -v pm2`)

## [hitl] Functional check

* run `fnm current` and confirm it shows a Node LTS version
* run `node --version` and `pnpm --version` and confirm both work
* run `pm2 status` and confirm pm2 is operational
