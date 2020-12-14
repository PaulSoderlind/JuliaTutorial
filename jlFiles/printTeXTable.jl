#------------------------------------------------------------------------------
"""
    printTeXTable(fh::IO,x,colNames=[],rowNames=[];width=12,prec=2)

Create LaTeX table from numeric matrix x
"""
function printTeXTable(fh::IO,x,colNames=[],rowNames=[];width=12,prec=2)

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
  str = string(str,endstr)

  print(fh,str,"\n")                                                    #print
  return nothing

end
                                      #when fh is not supplied: printing to screen
printTeXTable(x,colNames=[],rowNames=[];width=12,prec=2) =
printTeXTable(stdout::IO,x,colNames,rowNames,width=width,prec=prec)
#------------------------------------------------------------------------------
