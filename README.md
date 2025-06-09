docks
-----

A CLI tool for managing multiple screens into a docker compose container.

Usage
=====

Your project should contain a `.docks.yml` file, with the following structure:

```yaml
  prefix: myproj- # A prefix for your screen names
  container: dev # The name of the container to start
  screens: # A map of screens you can run for this project
    bash: bash # key is the name of the screen without the prefix; value is the command to run
```

```text
docks -h | --help | [-r {project root}] {command} <...args>
  -r {project root}  Set project root (defaults to pwd) or whatever
                     folder above contains '.docks.yml'
  start              Start all screens
  start {names...}   Start the screens named {names...}
  go {name}          Connect interactively with {name}
  kill               Kill all screens
  kill {names...}    Kill screens {names...}
  lsr                List running screens
  lsr {pattern}      List running screens matching {pattern} (egrep)
  lsc                List configured screens
  lsc {pattern}      List configured screens matching {pattern}
Logs are stored in `{project root}/{name}.log`
Screens are configured in `{project root}`/.docks.yml
```

