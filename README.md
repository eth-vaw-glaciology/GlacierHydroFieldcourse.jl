VAW Glaciology Field Course: Glacier Hydrology
==============================================

- the field instructions are in [`instructions/`](instructions).
- the Jupyter-notebooks in the [`notebooks/`](notebooks) folders which can be used to
  evaluate salt-dilution gauging data.
- if you prefere, you can do the same with the scripts in [`scripts/`](scripts).
- documentation (essentially the notebooks evaluated) is found in [`docs/`](docs), start with [`1_intro.md`](docs/1_intro.md).

# Installation
Install Julia with https://github.com/JuliaLang/juliaup

--> If you don't want to install git, you can also download the code as a zip file from github.

## Linux / Mac

- install with your Linux-distribution package manager or homebrew: `git`, `jupyter`
- open a terminal
- clone this repo
  - `git clone https://github.com/eth-vaw-glaciology/GlacierHydroFieldcourse.jl.git`
- change dir `cd GlacierHydroFieldcourse.jl`
- start Julia with current folder as project `julia --project`
- at the Julia repl (terminal) execute:
  `using Pkg; Pkg.update()`
  This will install all needed Julia packages.  It will take a while.

## Windows

- install PowerShell via the Windows App-Store
  https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701?hl=fr-ch&gl=CH
- install the git binaries from https://git-scm.com/download/win
  (presumably the 64-bit version)
  - the installer will ask you many questions.  Click "next" except
    when it asks for your Editor: probably use something other than
    VIM, say Notepad.

- open PowerShell by typing `Terminal` in the Windows-search
- change directory (folder) to somewhere good (use `cd`)
- clone this repo: `git clone https://github.com/eth-vaw-glaciology/GlacierHydroFieldcourse.jl.git`
- change dir `cd GlacierHydroFieldcourse.jl`
- start Julia with current folder as project `julia --project`
- at the Julia repl (terminal) execute:
  `using Pkg; Pkg.update()`
  This will install all needed Julia packages.  It will take a while.
- at the Julia prompt do `using IJulia` and `using PyPlot`.  This will
  most likely ask you to install Jupyter and Matplotlib via Conda.
  Say "yes"


# Running the code

Once install is completed, close Julia. Now
- if you want to work with notebooks:
  `cd notebooks` and
  - in Linux run `./start_notebook`
  - in Windows open Julia in the PowerShell with `julia --project` and
    then execute `using IJulia; notebook(dir=".")`
- if you want to work with text-files:
  `cd scripts` and run `julia --project`
  (edit the files in `scripts/` in your favourite text editor)

# Documentation

Documentation is found in [`docs/`](docs), start with [`1_intro.md`](docs/1_intro.md).
