# Visual inspection of sensor data

Here a few functions to visually inspect your data.
See `1_intro.jl`/`1_intro.ipynb` for an intro to Julia/Jupyter.

Load helper_functions.jl and plotting package (`PyPlot`)

````julia
include("helper_functions.jl")
using PyPlot
pygui(true) # to get an interactive, zoomable plot
            # (does not work when running a notebook on a server, only locally)
# pygui(false) # to get in-line plots
````

````
true
````

Function which does the plotting

````julia
"""
   plotit(filename, sensor, variable)

Plots the results from one file.
"""
function plotit(filename, sensor, variable=:cond)
    # load
    if sensor==:CTD
        d = read_Keller_DCX22_CTD(filename)
    elseif sensor==:DC22
        d = read_Keller_DC22(filename)
    elseif sensor==:DCX22
        d = read_Keller_DCX22(filename)
    else
        error("Don't know how to read data from sensor: $sensor")
    end
    # plot
    figure()
    plot(d[:t], d[variable])
    title("$filename, sensor=$sensor, variable=$variable")
end
````

````
Main.##434.plotit
````

Call above function to do the plotting.  Examples:

````julia
##plotit("../data/example_raw/DC_22627.TXT", :DCX22, :press) # TODO...
plotit("../data/example_raw/205144-10mH2O_12_08_2019-08_00_00.CSV", :CTD, :press)
````

````
PyObject Text(0.5, 1.0, '../data/example_raw/205144-10mH2O_12_08_2019-08_00_00.CSV, sensor=CTD, variable=press')
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

