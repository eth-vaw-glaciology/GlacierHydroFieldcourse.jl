# # Read in all traces
# This includes both the time series from the CTD sensors and the injection meta-data.

# Read sensor time series and concatenate the time series into one for each sensor

include("helper_functions.jl")
include("calibration.jl")

fls = Dict(:s145=>["../../data/2021/day1/205145-10mH2O_25_08_2021-09_00_00.CSV",
                   "../../data/2021/day2/205145-10mH2O_26_08_2021-08_30_00.CSV",
                   "../../data/2021/day3/205145-10mH2O_27_08_2021-08_30_00.CSV",
                   "../../data/2021/day4/205145-10mH2O_28_08_2021-08_30_00.CSV"],
           :s309=>["../../data/2021/day1/205309-100mH2O_25_08_2021-09_00_00.CSV",
                   "../../data/2021/day2/205309-100mH2O_26_08_2021-08_30_00.CSV",
                   "../../data/2021/day3/205309-100mH2O_27_08_2021-08_30_00.CSV",
                   "../../data/2021/day4/205309-100mH2O_28_08_2021-08_30_00.CSV"],
           :s049=>["../../data/2021/day1/296049.CSV",
                   "../../data/2021/day2/_26_08_2021-08_30_00.CSV",
                   "../../data/2021/day3/_27_08_2021-08_30_00.CSV",
                   "../../data/2021/day4/_28_08_2021-08_30_00.CSV"]
           )

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
    ## add calibration function
    sensor_readouts[sens][:cali_fn] = delta_cond2conc[sens]
end

figure()
for sens in keys(sensor_readouts)
    plot(sensor_readouts[sens][:t], sensor_readouts[sens][:cond])
end
legend(keys(sensor_readouts))
ylabel("Conductivity (μS/cm)")

# Read tracer metadata
metafile = "../../data/2021/tracer_metadata.csv"
d,h = readdlm(metafile, ',', header=true)

# # Make the individual traces

struct Trace
    nr
    location
    mass
    tinj
    tend
    sensors
    products
end

## Go through all meta-data lines and creates a Tracer-experiment for it
traces = []
for nr in 1:size(d,1)
    tinj = Dates.Date(d[nr,3], DateFormat("dd.mm.yyyy")) + Dates.Time(d[nr,4], "HH:MM")
    tend = Dates.Date(d[nr,3], DateFormat("dd.mm.yyyy")) + Dates.Time(d[nr,5], "HH:MM")

    ## figure out which sensors/loggers were used
    local sensor_name = Symbol.("s".*h[7:end])
    sensors = Dict()
    for snr=1:length(sensor_name)
        if d[nr, snr+6]!="x"
            sens = sensor_name[snr]
            loc = d[nr, snr+6]
            sensors[loc] = cut_sensor_readout(sensor_readouts[sens], tinj, tend)
            sensors[loc][:sensor_name] = sens
        end
    end


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
Plot a tracer experiment.
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
plot_trace(traces[1])
