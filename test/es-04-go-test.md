# Test Go (Go Toolchain)

## [auto] Go installation

* check if go is installed (`command -v go`)
* check if go version is reasonable (`go version`)

## [auto] Shlib integration

* check if ~/.shlib/shlibs/43-go-config.sh exists and contains GOPATH and PATH export
* check if .zshrc and .zshrc.lock are identical (shlib lock intact after go install)

## [auto] GOPATH

* check if ~/go/ directory exists (or is created on first go command)
* check if $GOPATH/bin is in PATH

## [hitl] Functional check

* run `go env GOPATH` and confirm it matches ~/go
* if lf was installed: run `lf --version` and confirm it works
