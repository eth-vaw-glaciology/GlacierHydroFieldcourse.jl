# Process traces

First runs scripts/notebooks `2_calibration` and `3_traces`.  Then
calculate:
- concentration
- discharge
- times of peaks
- background and peak concentrations

Writes output to

````julia
include("3_traces.jl")
pygui(false) # set to true to get interactive plots, false for in-line plots

using Statistics

"""
    make_concentration!(tr, num=15)

Calculate the concentration for a trace.  Assume that the first
`num` (15 by default) values are background and use that as an average.

Updates the trace in-place
"""
function make_concentration!(tr, num=15)
    for (loc, v) in tr.sensors
        tr.products[loc] = Dict()
        conc = v[:cali_fn](v[:cond])
        bkg = mean(conc[1:num])
        tr.products[loc]
        tr.sensors[loc][:conc] = conc .- bkg
        tr.products[loc][:background] = bkg
    end
    return nothing
end

"""
    integrate_concentration(t, conc, minconc=0.0)

Integrates the concentration time series.

Input:
- t -- times (s)
- conc -- concentration (g/l) time series (convert conductivity with f_readout2conc
          to a concentration)
- minconc -- if concentration drops below this value, discard that value

Output:

- integrated concentration (g s/l) == (kg s/ m^3)
"""
function integrate_concentration(t, conc, minconc=0.0)
    inds = conc.>minconc
    dt = t[2]-t[1]
    return sum(conc[inds]*dt) # approximate the integral by a sum
end

"""
    process_trace!(tr)

Process one trace at each sensor location/for each sensor:
- make concentration time series
- record background
- calc Q
- get peak concentration & time
"""
function process_trace!(tr)
    make_concentration!(tr)
    for loc in keys(tr.sensors)
        # calc discharge (m3/s)
        Q = tr.mass/1000/integrate_concentration(tr.sensors[loc][:tsec], tr.sensors[loc][:conc])
        tr.products[loc][:Q] = round(Q, sigdigits=2)
        # get time of peak in secs after injection
        peak_val, peak_ind = findmax(tr.sensors[loc][:conc])
        tr.products[loc][:peak_time] = tr.sensors[loc][:tsec][peak_ind]
        tr.products[loc][:peak_value] = peak_val
    end
    return nothing
end
````

````
Main.##432.process_trace!
````

Run the processing

````julia
process_trace!.(traces)
plot_trace(traces[1], :conc)
````
![](2389329343.png)

Write output CSV

````julia
function write_output(traces, fl)
    out = [["Experiment No", "Location", "Date" , "Injection time", "End time", "Salt mass [g]",
            145, 049, 309, "Q1", "Q2", "Q3", "t1", "t2", "t3"]]
    for tr in traces

        locdict = Dict(v[:sensor_name]=>k for (k,v) in tr.sensors)
        push!(out, [tr.nr, tr.location,  Dates.format(tr.tinj, "dd.mm.yyyy"), Dates.format(tr.tinj, "HH:MM:SS"),
                    Dates.format(tr.tend, "dd.mm.yyyy"), tr.mass,
                    get(locdict,:s145,"x"),
                    get(locdict,:s049,"x"),
                    get(locdict,:s309,"x"),
                    get(tr.products, 1, Dict(:Q=>NaN))[:Q],
                    get(tr.products, 2, Dict(:Q=>NaN))[:Q],
                    get(tr.products, 3, Dict(:Q=>NaN))[:Q],
                    get(tr.products, 1, Dict(:peak_time=>NaN))[:peak_time],
                    get(tr.products, 2, Dict(:peak_time=>NaN))[:peak_time],
                    get(tr.products, 3, Dict(:peak_time=>NaN))[:peak_time]])
    end
    writedlm(fl, out, ',')
end

write_output(traces, "output.csv")
````

This produces a CSV output file with the headers
`Experiment No,Location,Date,Injection time,End time,Salt mass [g],145,49,309,Q1,Q2,Q3,t1,t2,t3`
i.e. similar to the input `tracer_metadata.csv` but with added discharges and time-of-peak for
each sensor: [`output.csv`](output.csv)

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

