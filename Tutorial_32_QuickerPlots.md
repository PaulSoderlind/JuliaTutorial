# Get quicker (first) plot 

by using [PackageCompiler.jl](https://github.com/JuliaLang/PackageCompiler.jl)

This file contains instructions for how to create a Julia sysimage file (to speed up the plots) that
can be used for either working in the REPL or in IJulia.

0. Do `]add PackageCompiler`

1. Put this in a file `precompile_plots.jl`
```
using Plots
p = plot(rand(2,2))
scatter!(rand(3),rand(3)) #and perhaps some other plot commands that you use often
display(p)
```

2. The documentation of PackageCompiler.jl says: run the following and wait a few minutes
```
using PackageCompiler
create_sysimage(["Plots"], sysimage_path="sys_plots.so", precompile_execution_file="precompile_plots.jl")
```

3. Restart as `julia --sysimage D:/Julia/sys_plots.so` from the command line (change the folder as needed). Perhaps you want to create a desktop link for this.

4. Run the following and notice that it is fast
```
using Plots
plot(1:10)
```


5. For VS code, see
https://www.julia-vscode.org/docs/dev/userguide/compilesysimage/

6. To run IJulia, first install the kernel (change the folder as needed)
```
using IJulia
sysimage = "D:/Julia/sys_plots.so"
installkernel("Julia_sys_plots","--sysimage=$(sysimage)")
```
Now you can start jupyter as usual and select the kernel and perhaps run my Plots tutorial. You may have to change the kernel once you have opened an existing notebook.

7. Notice that if you want to take advantage of updated packages, then you need to recreate the sysimage.
