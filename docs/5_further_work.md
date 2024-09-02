# What next?

You now have the discharges and time between the detection sites.  What to do next?

````julia
include("4_process_traces.jl") # load previous work
````

````
Estimated linear fit: f(delta_cond) = a*conc with
 a = 0.00101±6.89e-5

Estimated linear fit: f(delta_cond) = a*conc with
 a = 0.000812±9.9e-5

Estimated linear fit: f(delta_cond) = a*conc with
 a = 0.000769±2.59e-15


````

## Stage-discharge relation and continuous Q

## Hydraulic friction Factor

## Other

- Make a map of the mapped moulin locations.  Superimpose it on an orthophoto
- Compare lake discharge to discharge of Gletsch https://www.hydrodaten.admin.ch/de/2268.html
- Try to infer the glacier-discharge from the lake discharge with `Q_in - Q_out = A * dh/dt`
- Compare discharge errors from different sensors / different detection locations
- If you mapped a catchment for the supraglacial streams, compare it to the melt-rates inferred
  by the mass-balance group.  Maybe even in a time-resolved manner...

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

