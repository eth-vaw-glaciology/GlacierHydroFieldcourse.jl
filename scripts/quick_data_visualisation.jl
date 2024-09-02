# # Visual inspection of sensor data
#
# Here a few functions to visually inspect your data.
# See `1_intro.jl`/`1_intro.ipynb` for an intro to Julia/Jupyter.

# Load helper_functions.jl and plotting package (`PyPlot`)

include("helper_functions.jl")
using GLMakie
Makie.inline!(false) # set to false for notebook inline plots

# Function which does the plotting
"""
   plotit(filename, sensor, variable=:cond)

Plots the results from one file.  By default into the current axis
"""
function plotit(filename, sensor, variable=:cond)
    ## load
    d = if sensor==:CTD
        read_Keller_DCX22_CTD(filename)
    elseif sensor==:DC22
        read_Keller_DC22(filename)
    elseif sensor==:DCX22
        read_Keller_DCX22(filename)
    elseif sensor==:WTW
        read_WTW(filename)
    else
        error("Don't know how to read data from sensor: $sensor")
    end
    ## plot
    lines(d[:t], d[variable])
    ## title("$filename, sensor=$sensor, variable=$variable")
end

# Call above function to do the plotting.  Example plotting the pressure:
plotit("../data/raw/example/205145-10mH2O_25_08_2021-09_00_00.CSV", :CTD, :press)
plotit("../data/raw/example-WTW/AD422041.CSV", :WTW, :cond)
