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

_parse_float(x) = x == "" ? NaN : x isa AbstractString ? parse(Float64, replace(x, "," => ".")) : Float64(x)

_round_to_second(t::DateTime) = round(t, Second)

function _column_index(headers, needle)
    i = findfirst(h -> occursin(needle, h), headers)
    i === nothing && error("Could not find column matching '$needle'")
    return i
end

function read_Keller(filename)
    if !isfile(filename)
        error("Filename $filename is not a file!")
    end
    firstline = open(filename, "r") do io
        readline(io)
    end
    if occursin("Serial Number", firstline)
        return read_Keller_logger5(filename)
    end

    d,h = readdlm(filename, ';', header=true)
    h = h[:]

    out = Dict{Symbol,Any}()
    it = _column_index(h, "Datetime [local time]")
    id = _column_index(h, "P1 [bar]")
    ic = _column_index(h, "Conductivity raw")
    itemp = _column_index(h, "TOB1 [°C]")

    out[:t] = [_round_to_second(DateTime(replace(split(s, ",")[1], "T" => " "), "y-m-d H:M:S") + Millisecond(length(split(s, ",")) > 1 ? parse(Int, lpad(split(s, ",")[2], 3, '0')) : 0)) for s in d[:,it]]
    out[:press] = [_parse_float(s) for s in d[:,id]] .* 1e5 / g / rhow
    out[:temp] = [_parse_float(s) for s in d[:,itemp]]
    out[:cond] = [_parse_float(s) for s in d[:,ic]] .* 1000
    return out
end
read_Keller_DCX22_CTD(filename) = read_Keller(filename)
read_Keller_DCX22(filename) = read_Keller(filename)
read_Keller_DC22(filename) = read_Keller(filename)

"""
    cut_sensor_readout(sensor_readout, tinj, tend)

Cuts the time series into individual tracer experiments.
"""
function cut_sensor_readout(sensor_readout, tinj, tend)

    iinj = findfirst(sensor_readout[:t].>tinj)
    iend = findlast(sensor_readout[:t].<tend)
    out = Dict()
    if iinj===nothing || iend===nothing || iinj==iend
        return out
    end
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

"""
        read_WTW(filename)

This function reads a file from the WTW conductivity sensor and
returns:

Dict with keys: :t [date-time stamp], :cond [μS/cm], :temp [C]

Note, that the input file usually contains several traces.  Split them up with
`split_conductivity_data`.
"""
function read_WTW(filename)
    if !isfile(filename)
        error("Filename $filename is not a file!")
    end
    if !startswith(splitdir(filename)[2], "AD")
        @warn("Read in a file starting with `AD`.  (The `AC` files use a comma for the decimal point.")
    end
    d, head = readdlm(filename, ';', header=true)
    out = Dict{Symbol,Any}() ## key has the be Symbol, value can be anything
    # time 12.08.2016 13:36:58
    fmt = "d.m.y H:M:S"
    out[:t] = [DateTime(dd, fmt) for dd in d[:,4]]
    # conductivity
    out[:cond] = d[:,5]
    units = d[:,6]
    @assert all(units.=="\xb5S/cm") "Units not in μS/cm!"
    # temp
    out[:temp] = d[:,8]

    # purge any records which are simultaneous (not sure why this happens with the WTW)
    purge = findall(diff(out[:t]).==Second(0))
    for p in reverse(purge)
        deleteat!(out[:t], p)
        deleteat!(out[:cond],p)
        deleteat!(out[:temp], p)
    end

    return out
end


###
````

````
Main.var"##277".read_WTW
````

Old file reader, probably not needed anymore

````julia
"""
         read_Keller_logger5(filename;
                             presshead="P1",
                             condhead="ConRaw",
                             temphead="TOB1",
                             skipstart=8,
                             )

Reads the old logger5 Keller pressure/CTD sensor format.

Returns a dict with keys as appropriate:
- :t [date-time stamp]
- :cond [μS/cm]
- :temp [C]
- :press [m H2O]
"""
function read_Keller_logger5(filename;
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
    out[:t] = [_round_to_second(Date(dd, fmtd) + Time(tt, fmtt)) for (dd,tt) in zip(d[:,id], d[:,it])]

    for (head, key) in [(presshead, :press),
                        (condhead, :cond),
                        (temphead, :temp)]
        i = findfirst(h.==head) ## see if there is one
        if i!=nothing
            out[key] = [_parse_float(s) for s in d[:,i]]
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

    for (k,v) in out
        if k != :t
            out[k] = Float64.(v)
        end
    end
    return out
end
````

````
Main.var"##277".read_Keller_logger5
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

