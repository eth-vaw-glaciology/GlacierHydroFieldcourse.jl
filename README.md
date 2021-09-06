VAW Glaciology Field Course: Glacier Hydrology
==============================================

- the field instructions are in `instructions/`
- the notebooks in the `notebook/` folders which can be used to
  evaluate salt-dilution gauging data.
- if you prefere, you can do the same with the scripts in `scripts/`

# Installation

This is for Linux (if you know what to do on Mac OS or Windows,
please let me know).

- install with your package manager: `git`, `matplotlib`, `jupyter`
- install Julia:
  - download the binaries from https://julialang.org/downloads/
  - unpack it with `tar xvvzf name-of-download.tar.gz` in a suitable
    location
  - make sure the `julia` executable is on your path, e.g. by setting
    a sym-link to `~/.local/bin`
- clone this repo: `git clone
  git@github.com:eth-vaw-glaciology/GlacierHydroFieldcourse.jl.git`
- change dir `cd GlacierHydroFieldcourse.jl`
- start Julia with current folder as project `julia --project`
- at the Julia repl (terminal) execute:
  `using Pkg; Pkg.update()`
  This will install all needed Julia packages.  It will take a while.

# Running the code

Once completed, close Julia. Now
- if you want to work with notebooks:
  `cd notebooks` and run `./start_notebook`
- if you want to work with text-files:
  `cd scripts` and run `julia --project`
  (edit the files in `scripts/` in your favourite text editor)

# Documentation

Documentation is found in [`docs/`](docs), start with [`1_intro`](blob/master/docs/intro.md).
