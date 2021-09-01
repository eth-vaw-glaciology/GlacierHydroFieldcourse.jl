using Literate

files = ["helper_functions.jl",
         "1_intro.jl",
         "2_calibration.jl",
         "3_traces.jl",
         "4_process_traces.jl",
         "5_further_work.jl",
         "run_them_all.jl",
         "quick_data_visualisation.jl"
         ]

"""
Replace "include" by nbinclude in notebooks.

Ref https://fredrikekre.github.io/Literate.jl/v2/customprocessing/
"""
function include2nbinclude(str)
    locs = findall("include(", str)
    length(locs)==0 && return str

    # insert `using NBInclude`
    loc_of_using = findprev('\n', str, locs[1][1])
    str = str[1:loc_of_using] * "using NBInclude\n" * str[loc_of_using+1:end]

    # replace includes with
    # @nbinclude("foo.ipynb"; softscope=true)
    locs = findall("include(", str) # refind due to shift
    for loc in reverse(locs)
        i1 = findnext('"', str, loc[2]+1)
        i2 = findnext('"', str, i1+1)
        fl = splitext(str[i1:i2])[1] * ".ipynb\""
        closing = findprev(')', str, findnext('\n', str, i2+1) )
        str = str[1:loc[1]-1] * "@nbinclude($fl)" * str[closing+1:end]
    end

    return str
end

# for fl in files
#     Literate.notebook(fl, outputdir="notebooks", preprocess=include2nbinclude)
# end
for fl in files
    Literate.markdown(fl, outputdir="../docs", execute=true, flavor = Literate.FranklinFlavor() )
end

# Literate.markdown("1_intro.jl", outputdir="../docs", execute=true, flavor = Literate.FranklinFlavor())
# Literate.markdown("quick_data_visualisation.jl", outputdir="../docs", execute=false, flavor = Literate.FranklinFlavor() )