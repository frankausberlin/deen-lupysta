# Test Ruby (rbenv & bundler)

## [auto] rbenv & ruby-build

* check if rbenv is installed (`command -v rbenv`)
* check if ruby-build is installed (`command -v ruby-build` or `rbenv install --list`)
* check if ~/.shlib/shlibs/45-ruby.sh exists and contains `rbenv init - zsh`
* check if .zshrc and .zshrc.lock are identical (shlib lock intact after ruby install)

## [auto] Ruby

* check if ruby is installed (`command -v ruby`)
* check if a global Ruby version is set (`rbenv global` returns a version, not "system")
* check if ~/.rbenv/versions/ has at least one version directory

## [auto] Bundler

* check if bundler is installed (`command -v bundle` or `gem list bundler`)

## [hitl] Functional check

* run `ruby --version` and confirm it shows the compiled version (not system ruby)
* run `bundle --version` and confirm it works
