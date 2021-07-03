#------------------------------------------------------------------------------
"""
    printTeXTable(fh::IO,x;colNames=[],rowNames=[],width=12,prec=2) or
    printTeXTable(x;colNames=[],rowNames=[],width=12,prec=2) or

Create LaTeX table from numeric matrix x. Print to file or screen and returns a string
with the table contents.

# Input
-`fh::IOStream`:
-`x::`:
-`colNames::`:
-`rowNames::`:
-`width::`:
-`prec::`:


"""
function printTeXTable(fh::IO,x;colNames=[],rowNames=[],width=12,prec=2)

  (m,n) = (size(x,1),size(x,2))

  isempty(rowNames) && (rowNames = [string("r",i) for i = 1:m])   #create row names "r1"
  isempty(colNames) && (colNames = [string("c",i) for i = 1:n])   #create column names "c1"

  str = """
  \\begin{table}
    \\begin{tabular}{l"""
  str = string(str,"r"^n,"}\n","    ")

  str = string(str," & ")                              #empty cell above rowNames[1]
  for i = 1:n-1                                        #column names
    str = string(str,colNames[i]," & ")
  end
  str = string(str,colNames[n]," \\\\ \\hline \n")

  for i = 1:m                                                          #loop over rows
    str = string(str,"   ",rowNames[i]," & ")                          #row name
    for j = 1:n-1
      str = string(str,fmtNumPs(x[i,j],width,prec,"right"), " & ")     #x[i,1:end-1]
    end
    str = string(str,fmtNumPs(x[i,n],width,prec,"right")," \\\\ \n")   #x[i,end]
  end

  endstr = """
    \\hline
    \\end{tabular}
  \\end{table}"""
  str = string(str,endstr,"\n")

  print(fh,str)                                                        #print

  return str

end
                                      #when fh is not supplied: printing to screen
printTeXTable(x;colNames=[],rowNames=[],width=12,prec=2) =
printTeXTable(stdout::IO,x;colNames,rowNames,width,prec)
#------------------------------------------------------------------------------
