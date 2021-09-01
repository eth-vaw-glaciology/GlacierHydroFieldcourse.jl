# # Field data evaluation
#
# Here scripts are provided to partially evaluate the salt tracer experiments.  After running these you will get a CSV-file
# with the output for each tracer experiment:
# - discharge at all detection points
# - time of peak concentration at all detection points

# ## Introduction to Julia and Jupyter notebooks
#
# The provided scripts you can run either as plain Julia scripts, i.e. text-files (ending in `.jl` in the folder `scripts/`) or
# as a [Jupyter notebook](https://jupyter.org/) (files ending in `.ipynb` in the folder `scripts/notebooks/`).
#
# The following scripts/notebooks are provided and should be looked-at and run in this order (or the `.ipynb` files if using notebooks):
# - `1_intro` this file
# - `2_calibration` to input and process your calibrations
# - `3_traces.jl` read CTD sensor data and partition into individual tracer experiments
# - `4_process_traces.jl` process the traces to produce discharges and peak-times
#
# Additionally there are the following files
# - `quick_data_visualisation.jl` allows to plot sensor data
# - `run_them_all.jl` runs all processing scripts/notebooks in order
# - `helper_functions.jl` various helper functions used in the scripts
# - (not needed by you: `export_to_md_ipynb.jl` creates the notebooks and web-markdown files from the julia scripts)

## Technical instructions
#
# You can run the code
#
# The notebook is a [Jupyter notebook](https://jupyter.org/) (formerly iPython notebook) which allows combining notes (in [markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)), codes and plots.  For documentation see [here](http://jupyter-notebook.readthedocs.io/en/latest/examples/Notebook/Notebook%20Basics.html), but you should be able to get by with the documentation I provide below.
#
# To get the notebook running (what you're looking at right now is probably the non-inteactive html-rendered version of the notebook) do:
#
# - log into the practicum account on a linux machine
# - open a terminal and type: `cd fieldcourse/surface-hydrology/` + enter, `julia` + enter
# - once started type `using IJulia` + enter and `notebook()` + enter (this will take a few seconds).
# - this should open a file-browser dialog in your internet-browser (if it doesn't open a browser and navigate to [localhost:8888](http://localhost:8888), by clicking the link).  Click on `Salt-dilution.ipynb` which should open a new tab.  The tab should look like the html-version of the notebook you looked at so far but is now fully functional, i.e. you can edit it and exectue code.

# If you want to run this on your own computer you'll have to install [Julia](http://www.julialang.org/downloads) and install the packages `IJulia`, `NBInclude`, `PyPlot`, `LsqFit`, `CSV` by running at the Julia prompt: `using Pkg; [Pkg.add(s) for s in ["IJulia", "NBInclude", "PyPlot", "LsqFit", "CSV"]]`.

# The important **notebook commands** are:

# - clicking or double-clicking into a cell allows you to edit it.
# - pressing **shift+enter** evaluates it: for a cell like the one you are reading now it renders the markdown, for code cells it evaluates the code and prints/displays the output of the last line of code.  Use a `;` to supress the output.
# - variables and functions defined in one cell will be available for use in cells evaluated afterwards (irrespective of whether the cell is above or below).
# - if you change a code-cell and re-evaluate it, the cells depending on its variables are not evaluated again automatically.
# - somtimes it is good to re-start the computation and re-evaluated all cells. Go to drop down menu `Kernel -> Restart and run all`
# - there is **no undo**! E.g. if you mark the contents of a cell and press backspace, it's gone, bye-bye!  Thus save often (disk-icon top left).  It should also auto-save but still, save often.  To revert to the last save go to menu `File -> Revert to Checkpoint` (this is as close to undo as it gets!).
# - To insert a new, empty cell got to the menu `Insert`
# - To change the type of the cell use the drop-down menu which displays `Code` by default.
# - To export the notebook as a pdf, html, etc. got to drop-down menu `File -> Download as`. (Note, to save single figures, you can use the command `savefig("example.png")`.)

# Plots: to export plots it may be easiest if you right-click on it an choose "Save image as".

# ## Julia

# This notebook uses the Julia programming language, which is a new technical programming language.  Its syntax is fairly close to Matlab and not far off Python, at least for easy stuff, to which I'll stick to here.  Notable differences to Matlab are:

# - indexing is done with `[]`, e.g. `a[3]`.
# - functions can be defined in-line and don't need their own m-file

# Differences to python:

# - indexing starts at 1
# - indentation does not matter, instead blocks/functions, etc are closed with `end`.


# Documentation for Julia can be found [here](http://docs.julialang.org).  If you're interested to get started with Julia (which I can reccommend) have a look at [these](https://www.youtube.com/playlist?list=PLP8iPy9hna6SCcFv3FvY_qjAmtTsNYHQE) video tutorials, or above docs.
