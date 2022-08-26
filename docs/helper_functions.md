# Various helper functions

## Fit calibration

````julia
using LsqFit ## a package for least square fitting
"""
    fit_calibration(bucketsize, solution, calis...)

Fits a line of best fit through the calibration data going through the origin.
Returns the function of this line: `f(cond-cond_at_0) -> concentration`.

Also prints the parameters values +/- 95% confidence intervals.

Uses the package LsqFit: https://github.com/JuliaOpt/LsqFit.jl
"""
function fit_calibration(bucketsize, solution, calis...)
    # subtract readout at zero concentration
    for c in calis
        @assert c[1,1]==0 "First row needs to be zero reading!"
        c[:,2] .= c[:,2].-c[1,2]
    end
    # concatenate all calibrations
    cali = vcat(calis...)
    conc = ml_to_concentration(cali[:,1], solution, bucketsize)
    delta_readout = cali[:,2]
    # Fit line using https://github.com/JuliaOpt/LsqFit.jl
    fn(delta_readout, p) = p[1]*delta_readout ## p[1]==a, p[2]==b
    para_weights = [0.5] ## equal weights to parameters
    fit = curve_fit(fn, delta_readout, conc, para_weights)
    errors = margin_error(fit, 1-0.95)
    println("""
    Estimated linear fit: f(delta_cond) = a*conc with
     a = $(round(fit.param[1],sigdigits=3))±$(round(errors[1],sigdigits=3))
    """)
    return (delta_readout) -> fn(delta_readout, fit.param)
end;
````

## Read Keller sensors

````julia
using Dates
using DelimitedFiles: readdlm, writedlm ## Date time handling; CSV file handling
const g = 9.81
const rhow = 1000.0

"""
         read_Keller(filename;
                     presshead="P1",
                     condhead="ConRaw",
                     temphead="TOB1",
                     skipstart=8,
                     )

Reads a Keller pressure/CTD sensor.  However, you probably want to use
- `read_Keller_DCX22_CTD`,
- `read_Keller_DCX22` and
- `read_Keller_DC22`

Returns a dict with keys as appropriate:
- :t [date-time stamp]
- :cond [μS/cm]
- :temp [C]
- :press [m H2O]
"""
function read_Keller(filename;
                     presshead="P1",
                     condhead="ConRaw",
                     temphead="TOB1",
                     skipstart=8,
                     )
    d,h = readdlm(filename, ';', skipstart=skipstart, header=true)
    h = h[:] ## h is a 1x2 matrix, change to a vector

    out = Dict{Symbol,Any}()
    # find date-time rows
    id, it = findfirst(h.=="Date"), findfirst(h.=="Time")
    # time 12.08.2016 13:36:58
    fmtd, fmtt = "d/m/y", "H:M:S"
    out[:t] = [Date(dd, fmtd) + Time(tt, fmtt) for (dd,tt) in zip(d[:,id], d[:,it])]

    for (head, key) in [(presshead, :press),
                        (condhead, :cond),
                        (temphead, :temp)]
        i = findfirst(h.==head) ## see if there is one
        tmp = Float64[]
        if i!=nothing
            out[key] = [s=="" ? missing :
                        s isa AbstractString ? parse(Float64, replace(s, ","=>".")) : Float64(s) for s in d[:,i]]
            # convert mS/cm to μS/cm
            if key==:cond
                out[:cond] = out[:cond].*1000
            end
            # convert pressure from mbar to m H2O
            if key==:press
                out[:press] = out[:press]*1e2 /g/rhow
            end
        end
    end

    # check lengths and remove all "missing"
    l = length(out[:t])
    topurge = []
    for v in values(out)
        @assert length(v)==l
        append!(topurge, findall(v.===missing))
    end
    topurge = sort(unique(topurge))
    for (k,v) in out
        deleteat!(v, topurge)
        if k!=:t
            out[k] = Float64.(v) ## make the vector an
        end
    end
    return out
end

read_Keller_DCX22_CTD(filename) = read_Keller(filename)
read_Keller_DCX22(filename) = read_Keller(filename, error("Not implement yet"))

"""
    cut_sensor_readout(sensor_readout, tinj, tend)

Cuts the time series into individual tracer experiments.
"""
function cut_sensor_readout(sensor_readout, tinj, tend)

    iinj = findfirst(sensor_readout[:t].>tinj)
    iend = findfirst(sensor_readout[:t].>tend)-1
    out = Dict()
    for (k,v) in sensor_readout
        if v isa Vector
            out[k] = v[iinj:iend]
        else
            out[k] = v
        end
    end
    # add time in secs since injection
    t = sensor_readout[:t]
    tt = convert(Vector{Float64}, Dates.value.(t[iinj:iend]-t[iinj])/1000)
    out[:tsec] = tt
    return out
end
````

````
Main.##288.cut_sensor_readout
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

