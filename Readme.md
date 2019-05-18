# Notice 
If GitHub fails to render the notebook, then use [nbviewer](https://nbviewer.jupyter.org/). Instructions: try to open the notebook in GitHub, copy the link and paste it in the address field of nbviewer.


# Introduction

This folder contains my Julia tutorials (aimed at students in finance and economics). 

*  Most files are jupyter notebooks. Click one of them to see it online. Sometimes it renders better if you activate the nbviewer (see the symbol in the upper right corner once you have opened the file).
*  To edit and run it online, use www.JuliaBox.com. It has many packages installed. In case you need further packages, see the top menu at JuliaBox.com. To get this repository to JuliaBox, use the Download (as zip) in the Github menu, unzip, then use JuliaBox to upload.
*  To edit and run it with your local Julia installation do the following: (a) start Julia; (b) ```cd(file location)```; (c) ```using IJulia```; (d) ```notebook(dir=pwd())``` or use [nteract](https://nteract.io/). You clearly need [IJulia](https://github.com/JuliaLang/IJulia.jl) to be installed for this. 
*  The subfolder Data contains some data sets used in the programs, while the subfolder Results is for output.

On the files:

1. The .jl files are functions used in some of the notebooks.

2. Tutorial_ChapterNumber_Topic.ipynb are (relatively) short notebooks organised around different topics.

3. The current version is tested on Julia 1.1.
