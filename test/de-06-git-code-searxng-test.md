# Test Git, Code & SearXNG

## [auto] Git configuration

* check if ~/.gitignore_global exists
* check if `git config --global core.excludesfile` points to ~/.gitignore_global
* check if `git config --global user.name` is set
* check if `git config --global user.email` is set
* check if `git config --global init.defaultBranch` is set to main
* check if `git config --global pull.rebase` is true

## [hitl] GitHub CLI authentication

* run `gh auth status` and confirm SSH auth is active (not HTTPS token)
* confirm the uploaded key is id_ed25519.pub

## [auto] VSCode

* check if code is installed (`which code`)
* check if /etc/apt/sources.list.d/vscode.list exists
* check if /etc/apt/keyrings/packages.microsoft.gpg exists

## [hitl] VSCode nautilus integration (desktop only)

* right-click in Nautilus and confirm "Open with Code" appears in context menu

## [auto] SearXNG

* check if ~/.searxng/config/ and ~/.searxng/data/ exist
* check if ~/.searxng/config/settings.yml exists
* check if secret key is not "ultrasecretkey" (has been replaced)
* check if JSON format is enabled in settings.yml
* check if searxng docker container is running (`docker ps | grep searxng`)
* check if container is bound to 127.0.0.1:8080 (not 0.0.0.0)
* check if ~/.shlib/settings_searxng.yml comfort link exists

## [hitl] SearXNG functional check

* open http://localhost:8080 and confirm SearXNG search page loads
* run a test search and confirm JSON format works: `curl -s "http://localhost:8080/search?q=test&format=json" | jq .`
