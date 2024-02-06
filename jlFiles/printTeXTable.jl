"""
    printTeXTable([fh::IO,]x;colNames=[],rowNames=[],width=12,prec=2) or

Create LaTeX table from numeric matrix x. Print to file or screen and returns a string
with the table contents.

# Input
-`fh::IOStream`:       handle of open file, optional
-`x::VecOrMat`:        numbers for the table
-`colNames::Vector`:   of strings, column names
-`rowNames::Vector`:   of string, row names
-`width::Int`:         width of numerical cells
-`prec::Int`:          number of digits of numerical cells

# Requires
- fmtNumPs from the printmat.jl file


"""
function printTeXTable(fh::IO,x;colNames=String[],rowNames=String[],width=12,prec=2)

  (m,n) = (size(x,1),size(x,2))

  isempty(rowNames) && (rowNames = [string("r",i) for i = 1:m])   #create row names "r1"
  isempty(colNames) && (colNames = [string("c",i) for i = 1:n])   #create column names "c1"

  str = """
  \\begin{table}
    \\begin{tabular}{l$(repeat("r",n))}\n    """                    #beginning of table

  str = string(str," & ",join(colNames," & ")," \\\\ \\hline \n")   #row names and hline
  for i = 1:m                                                       #loop over rows
    str = string( str,"   $(rowNames[i]) & ",
                  join(fmtNumPs.(x[i,:],width,prec,"right")," & ")," \\\\ \n" )
  end

  str = string(str,"  \\hline\n  \\end{tabular}\n\\end{table}\n")   #end of table

  print(fh,str)                                                     #print

  return str

end

                                       #when fh is not supplied: printing to screen
printTeXTable(x;colNames=String[],rowNames=String[],width=12,prec=2) =
printTeXTable(stdout::IO,x;colNames,rowNames,width,prec)
