# Test Java (SDKMAN!)

## [auto] SDKMAN!

* check if ~/.sdkman/ exists
* check if ~/.shlib/shlibs/44-java.sh exists and contains SDKMAN_DIR and sdkman-init.sh source
* check if .zshrc and .zshrc.lock are identical (shlib lock intact after sdkman install)

## [auto] JDK

* check if java is installed (`command -v java`)
* check if java version is 21 (`java -version 2>&1 | grep "21."`)
* check if `sdk current java` shows the installed version

## [auto] Build tools

* check if maven is installed (`command -v mvn`)
* check if gradle is installed (`command -v gradle`)

## [hitl] Shlib hygiene

* check that .zshrc does NOT contain SDKMAN's auto-generated snippet at the end (it should only be in shlib)
* run `sdk version` and confirm SDKMAN is operational

## [hitl] Functional check

* run `java -version` and confirm it shows the correct LTS version
* run `mvn -version` and `gradle -version` and confirm both work
