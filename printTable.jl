"""
    printTable([fh::IO],x,colNames=[],rowNames=[];width=10,prec=3,NoPrinting=false,htmlQ=false)

Print formatted row names (1st column) column names (1st row), and data matrix (the rest).

See printmat() for (width,prec)

To do: (a) allow for different n-vectors width&prec

"""
function printTable(fh::IO,x,colNames=[],rowNames=[];width=10,prec=3,NoPrinting=false,htmlQ=false)

  isempty(x) && return nothing                        #do nothing is isempty(x)

  (m,n) = (size(x,1),size(x,2))

  if isempty(rowNames)                                 #create row names "r1"
    rowNames = [string("r",i) for i = 1:m]
  end
  if isempty(colNames)                                 #create column names "c1"
    colNames = [string("c",i) for i = 1:n]
  end

  rNamesWidth = maximum([length(rowNames[i]) for i = 1:length(rowNames)])  #max length of rowNames

  if htmlQ                                             #print column names
    cNamesStr = string("<tr><td>",rpad("",rNamesWidth),"</td>")
    for i = 1:n
      cNamesStr = string(cNamesStr,"<th>",lpad(colNames[i],width),"</th>")
    end
    cNamesStr = string(cNamesStr,"</tr>")
  else
    cNamesStr = rpad("",rNamesWidth)                     #"" for cell 0,0
    for i = 1:n                                          #create string
      cNamesStr = string(cNamesStr,lpad(colNames[i],width))
    end
  end

  xStr  = printmat(fh,x,width=width,prec=prec,NoPrinting=true,htmlQ=htmlQ)   #body of table, one long string
  xStrV = split(xStr,"\n")                       #vector of strings (one per row of x)

  iob = IOBuffer()
  write(iob,cNamesStr,"\n")
  for i = 1:m                           #loop over rows in x, print rowNames[i] and x[i,:]
    if htmlQ
      write(iob,"<tr><td><b>",rpad(rowNames[i],rNamesWidth),"</td></b>",xStrV[i],"</tr> \n")
    else
      write(iob,rpad(rowNames[i],rNamesWidth),xStrV[i],"\n")
    end
  end
  str = String(take!(iob))

  if NoPrinting                              #no printing, just return str
    return str
  else                                       #print, return nothing
    print(fh,str,"\n")
    return nothing
  end

end
                        #when fh is not supplied: printing to screen
printTable(x,colNames=[],rowNames=[];width=10,prec=3,NoPrinting=false,htmlQ=false) =
printTable(stdout::IO,x,colNames,rowNames,
                      width=width,prec=prec,NoPrinting=NoPrinting,htmlQ=htmlQ)
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    printTable2

Call on printTable2 twice: to print to screen and then to an open file (IOStream)
"""
function printTable2(fh,x,colNames=[],rowNames=[];width=10,prec=3,NoPrinting=false,htmlQ=false)
  printTable(x,colNames,rowNames,width=width,prec=prec,NoPrinting=NoPrinting,htmlQ=htmlQ)      #to screen
  if isa(fh,IOStream) && isopen(fh)
    printTable(fh,x,colNames,rowNames,width=width,prec=prec,NoPrinting=NoPrinting,htmlQ=htmlQ) #to file
  end
end
#------------------------------------------------------------------------------
