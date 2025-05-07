# Introduction

This repository contains my Julia tutorials (aimed at students in finance and economics). 


# Instructions

1. Most files are jupyter notebooks. Click one of them to see it online. If GitHub fails to render the notebook, then use [nbviewer](https://nbviewer.jupyter.org/). Instructions: try to open the notebook at GitHub, copy the link and paste it in the address field of nbviewer.

2. A pdf file contains a print-out of all notebooks.  

3. To download this repository, use the Download (as zip) in the Github menu. Otherwise, clone it.


# On the Files

1. Tutorial_ChapterNumber_Topic.ipynb are (relatively) short notebooks organised around different topics.

2. NotebooksAsPDF.pdf is a print-out of all notebooks. 

3. The folder src contains .jl files with functions used in the notebooks.

4. The folder Data contains some data sets used in the notebooks, while the folder Results is for output.

5. The plots are in png format. If you want sharper plots, change `default(fmt = :png)` to `default(fmt = :svg)` in one of the top cells.

6. The current version is tested on Julia 1.11.
