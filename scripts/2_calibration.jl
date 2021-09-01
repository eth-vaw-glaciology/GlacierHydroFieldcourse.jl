# # Calibration
#
# The aim is to find the slope between sensor readout (μS/cm) and concentration (g/l) for each sensor

bucketsize = 1.0 # calibration bucket size in liters
solution_conc = 1.0 # calibration solution concentration (g/l)

# total calibration ml solution vs sensor readout (μS/cm) for each sensor

calibrations = Dict(
:s049=>[
    ## first calibration on 25.8.2021 at 14:28; sensor 049
    [ 0 0 ## First row needs to be the background reading!
      1 0.34 ## Note, that background reading will probably be much different for you
      5 3.84
      10 9.6
      20 25.4
      40 50.7
      90 107.3
      130 149 ],
    ## second calibration 26.8.2021 at 9:33; sensor 049
    [ 0 0.63
      1 1.52
      2 2.49
      5 5.5
      10 11.5
      20 29.5
      40 53.7
      90 112
      130 156 ],
    ##third calibration 28.08.2021 at 12:27, sensor 049
    [ 0 1.07
      1 2.06
      2 3.08
      5 6.11
      10 12.6
      13 17.5 ]
],
:s145=>[## first calibration on 25.8.2021 at 14:28; sensor 145
      [ 0 0.31 ## First row needs to be the background reading!
        1 1.03 ## Note, that background reading will probably be much different for you
        5 4.29
        10 9.9 ],
      ## 20 24.3
      ##40 49.1
      ##90 105
      ##130 148.5
      ## second calibration 26.8.2021 at 9:33; sensor 145
      [ 0 1.21
        1 2.14
        2 3.03
        5 5.88
        10 11.83 ],
      ##20 29
      ## 40 53
      ##90 111
      ##130 155
      ## third calibration 28.8.2021 at 12:27; sensor 145
      [ 0 1.76
        1 2.65
        2 3.64
        5 6.36
        10 12.2 ]
      ## 13 17.4 ]
      ],
:s309=>[
## first calibration on 25.8.2021 at 14:28; sensor 309
[ 0 0.54 ## First row needs to be the background reading!
  1 1.35 ## Note, that background reading will probably be much different for you
  5 4.7
  10 9.7
  20 24.4 ],
## 40 49.7
## 90 103
## 130 141
## second calibration 26.8.2021 at 9:33; sensor 309
[ 0 1.6
  1 2.43
  2 3.34
  5 6.23
  10 12.3
  20 28.6 ],
##  40 52.1
##  90 109
## 130 152
## third calibration 28.8.2021 at 12:27; sensor 309
 [ 0 2.05
   1 2.99
   2 3.99
   5 6.89
   10 13.1
   13 17.2 ]
])

# Convert ml solution added to concentration

"""
Converts ml added to bucket to a concentration (g/l == kg/m^3).

Input:

- ml -- how many mililiters were added
- solution_conc -- the concentration of the calibration solution (kg/m^3 == g/l)
- bucketsize -- the size of the bucket/bottle to which the solution was added (l)

Output:

- concentration (kg/m^3 == g/l)
"""
function ml_to_concentration(ml, solution_conc, bucketsize)
    mass = ml/1e3 * solution_conc # salt mass added to bucket (g)
    return mass/bucketsize # concentration in g/l (== kg/m^3)
end
# An example, convert to concentration (g/l):
ml_to_concentration(calibrations[:s049][1][:,1], solution_conc, bucketsize)

# Now fit a linear function to it.  The function is pre-defined in the file helper_functions.jl with
# name `fit_calibration`.
include("helper_functions.jl")

delta_cond2conc = Dict(a[1] => fit_calibration(bucketsize, solution_conc, a[2]...) for a in pairs(calibrations))

# Plot them

using PyPlot

# Note if you want a zoom-able plot opening in a new window do:
#pygui(true)
# to go back to in-line plots do
#pygui(false)

fig = figure()
for (i,sens) in enumerate(keys(delta_cond2conc))
    subplot(length(delta_cond2conc), 1, i)
    delta_fn = delta_cond2conc[sens]
    calis = calibrations[sens]
    ## scatter plots (x,y) points
    maxreadout = 0
    for cali in calis
        conc = ml_to_concentration(cali[:,1], solution_conc, bucketsize)
        maxreadout = max(maxreadout, maximum(cali[:,2].-cali[1,2]))
        scatter(conc, cali[:,2].-cali[1,2],
                label="Calibration 1")
    end
    xlabel("concentration (g/l)")
    ylabel("Sensor readout change (μS/cm)")

    ## Now plot the line of best fit:
    readouts = 0:maxreadout
    ## (plot plots a line)
    plot(delta_fn(readouts), readouts, label="line of best fit")
    title(sens)
end

#savefig("../plots/calibration.png") # to save this figure to a file, useful for your presentation
