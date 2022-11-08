# Get quicker (first) plot 

by using [PackageCompiler.jl](https://github.com/JuliaLang/PackageCompiler.jl)

This file contains instructions for how to create a Julia sysimage file (to speed up the plots, CSV and DataFrames) that
can be used for either working in the REPL or in IJulia.

0. Do `]add PackageCompiler`

1. Put this in a file `precompile_PS.jl`
```
using Plots

p = plot(rand(2,2))
scatter!(rand(3),rand(3))
display(p)

using Dates, CSV, DataFrames
DataFile = "Data/Options_prices_US_Canada.csv"
df1 = CSV.read(DataFile,DataFrame,normalizenames=true,dateformat="mm/dd/yy")

df1.date       .+= Dates.Year(2000)     #03/30/17 to 03/30/2017
df1.expiration .+= Dates.Year(2000)

select!(df1,Not([:exchange,:option_symbol,:style,:unadjusted]))  #deleting some columns
rename!(df1,:adjusted_close => :close)          #renaming a column
show(df1)
```
You clearly need the file `Data/Options_prices_US_Canada.csv` for this to run. It's available in the repository.


2. The documentation of PackageCompiler.jl says: run the following and wait a few minutes
```
using PackageCompiler
create_sysimage(["Plots","CSV","DataFrames"], sysimage_path="sys_PS.so", precompile_execution_file="precompile_PS.jl")
```

3. Restart as `julia --sysimage D:/Julia/sys_PS.so` from the command line (change the folder as needed). Perhaps you want to create a desktop link for this.

4. Run some Julia code (with plots and CSV/DataFrames) notice that it is fast. For instance, rerun the Julia code in `precompile_PS.jl`.


5. For VS code, see
https://www.julia-vscode.org/docs/dev/userguide/compilesysimage/

6. To run IJulia, first install the kernel (change the folder as needed)
```
using IJulia
sysimage = "D:/Julia/sys_PS.so"
installkernel("Julia_sys_PS","--sysimage=$(sysimage)")
```
Now you can start jupyter as usual and select the kernel and perhaps run my Plots tutorial. You may have to change the kernel once you have opened an existing notebook.

7. Notice that if you want to take advantage of updated packages, then you need to recreate the sysimage.
