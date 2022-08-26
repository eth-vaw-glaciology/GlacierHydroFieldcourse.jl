# # Read in all traces and store them in a suitable data-structure
#
# Tracer data entails both the time series from the CTD sensors itself as well as the injection meta-data.
# The metadata is stored in a CSV-file which you'll need to fill in.

## Load calibration script (also includes helper_functions.jl)
include("2_calibration.jl")
## set to true to get interactive plots, false for in-line plots
pygui(false);

# Now load data-files from CTD sensors

## for each sensor list all data-files
fls = Dict(:s145=>["../data/raw/example/205145-10mH2O_25_08_2021-09_00_00.CSV",
                   "../data/raw/example/205145-10mH2O_26_08_2021-08_30_00.CSV"],
           :s309=>["../data/raw/example/205309-100mH2O_25_08_2021-09_00_00.CSV",
                   "../data/raw/example/205309-100mH2O_26_08_2021-08_30_00.CSV"],
           ## :s049=>[],
           ## :s999
           )

## Read sensor time series and concatenate the time series into one for each sensor
sensor_readouts = Dict()
for sens in keys(fls)
    local out = read_Keller_DCX22_CTD(fls[sens][1])
    for fl = fls[sens][2:end]
        tmp = read_Keller_DCX22_CTD(fl)
        for (k,v) in tmp
            out[k] = [out[k]; tmp[k]]
        end
    end
    sensor_readouts[sens] = out
    ## add calibration function (from 2_calibration.jl)
    sensor_readouts[sens][:cali_fn] = delta_cond2conc[sens]
end

## Plot concatenated conductivity time-series for all sensors
fig = figure()
for sens in keys(sensor_readouts)
    plot(sensor_readouts[sens][:t], sensor_readouts[sens][:cond])
end
legend(keys(sensor_readouts))
ylabel("Conductivity (μS/cm)")
fig

#md savefig("../docs/cond-timeseries.png") #hide
#md # ![](cond-timeseries.png)

# Read tracer metadata.  This CSV-file needs to have the format
#
# `Experiment No,Location,Date, Injection time, End time, Salt mass [g], 145, 049, 309`
#
# (add more sensors to the back if needed, or remove some if not needed)
metafile = "../data/raw/example/tracer_metadata.csv"
d,h = readdlm(metafile, ',', header=true)

# # Make the individual traces

"""
A data-structure to hold data from one trace
"""
struct Trace
    nr
    location
    mass
    tinj
    tend
    sensors
    products
end

## Go through all meta-data lines (from the CSV-file) and creates a Tracer-experiment for it
traces = []
for nr in 1:size(d,1)
    ## parse times:
    tinj = Dates.Date(d[nr,3], DateFormat("dd.mm.yyyy")) + Dates.Time(d[nr,4], "HH:MM")
    tend = Dates.Date(d[nr,3], DateFormat("dd.mm.yyyy")) + Dates.Time(d[nr,5], "HH:MM")

    ## figure out which sensors/loggers were used
    local sensor_name = Symbol.("s".*h[7:end])
    sensors = Dict()
    for snr in 1:length(sensor_name)
        sens = sensor_name[snr]
        if !haskey(sensor_readouts, sens)
            @warn("No data for sensor $sens")
            continue
        end
        if d[nr, snr+6]!="x"
            loc = d[nr, snr+6]
            sensors[loc] = cut_sensor_readout(sensor_readouts[sens], tinj, tend)
            sensors[loc][:sensor_name] = sens
        end
    end

    ## create an instance of the Trace-struct and push it to the list holding all traces
    push!(traces,
          Trace(nr,
           d[nr,2],
           Float64(d[nr,6]),
           tinj,
           tend,
           sensors,
           Dict()
           ))
end

"""
    plot_trace(tr, field=:cond)

Function to plot a tracer experiment, possibly consisting of
several detectors.
"""
function plot_trace(tr, field=:cond)
    f = figure()
    for (k,sens) in tr.sensors
        plot(sens[:tsec], sens[field])
    end
    if isempty(tr.products)
        legend([v[:sensor_name] for (k,v) in tr.sensors])
    else
        legend(["$(v[:sensor_name]), loc=$k, Q=$(round(tr.products[k][:Q], sigdigits=2)) m³/s" for (k,v) in tr.sensors])
    end
    if field==:cond
        ylabel("Conductivity (μS/cm)")
    end
    xlabel("Time since injection (s)")
    return f
end

## Example
plot_trace(traces[2])

#md savefig("../docs/multi-trace.png") #hide
#md # ![](multi-trace.png)
