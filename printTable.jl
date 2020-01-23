"""
    printTable([fh::IO],x,colNames=[],rowNames=[];
               width=10,prec=3,NoPrinting=false,htmlQ=false,cell00="")

Print formatted table with row names (1st column) column names (1st row), and data matrix (the rest).


# Input
- `fh::IO`:           (optional) file handle. If not supplied, prints to screen
- `x::Array`:         string, date or array to print
- `width::Int`:       (keyword) scalar, width of printed cells. [10]
- `prec::Int`:        (keyword) scalar, precision of printed cells. [3]
- `NoPrinting::Bool`: (keyword) bool, true: no printing, just return formatted string [false]
- `hmtlQ::Bool`:      (keyword) bool, true: format as htmlQ <td>cells</td> [false]
- `cell00::String`:   (keyword) string, for row 0, column 0

# Output
- `str::String`:      (if NoPrinting) string, (otherwise nothing)

# Example
```
xA = [1 "ab" "abc"; "ccc" 3.14 missing]
printTable(xA,colNames,["1";"4"],width=12,prec=2)
```

# Uses
- printmat

"""
function printTable(fh::IO,x,colNames=[],rowNames=[];
                    width=10,prec=3,NoPrinting=false,htmlQ=false,cell00="")

  isempty(x) && return nothing                        #do nothing is isempty(x)

  (m,n) = (size(x,1),size(x,2))

  if isempty(rowNames)                                 #create row names "r1"
    rowNames = [string("r",i) for i = 1:m]
  end
  if isempty(colNames)                                 #create column names "c1"
    colNames = [string("c",i) for i = 1:n]
  end

  rNamesWidth = maximum([length(rowNames[i]) for i = 1:length(rowNames)])  #max length of rowNames
  rNamesWidth = max(rNamesWidth,length(cell00))

  if htmlQ                                             #print column names
    cNamesStr = string("<tr><th>",lpad(cell00,rNamesWidth),"</th>")
    for i = 1:n
      cNamesStr = string(cNamesStr,"<th>",lpad(colNames[i],width),"</th>")
    end
    cNamesStr = string(cNamesStr,"</tr>")
  else
    cNamesStr = lpad(cell00,rNamesWidth)                 #cell 0,0
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
printTable(x,colNames=[],rowNames=[];width=10,prec=3,NoPrinting=false,htmlQ=false,cell00="") =
printTable(stdout::IO,x,colNames,rowNames,
                      width=width,prec=prec,NoPrinting=NoPrinting,htmlQ=htmlQ,cell00=cell00)
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    printTable2

Call on printTable2 twice: to print to screen and then to an open file (IOStream)
"""
function printTable2(fh,x,colNames=[],rowNames=[];width=10,prec=3,NoPrinting=false,htmlQ=false,cell00="")
  printTable(x,colNames,rowNames,width=width,prec=prec,NoPrinting=NoPrinting,htmlQ=htmlQ,cell00=cell00)      #to screen
  if isa(fh,IOStream) && isopen(fh)
    printTable(fh,x,colNames,rowNames,width=width,prec=prec,NoPrinting=NoPrinting,htmlQ=htmlQ,cell00=cell00) #to file
  end
end
#------------------------------------------------------------------------------
