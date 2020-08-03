#------------------------------------------------------------------------------
"""
    printmat([fh::IO],x;width=10,prec=3,NoPrinting=false,StringFmt="")

Print all elements of matrix with predefined formatting.

# Input
- `fh::IO`:            (optional) file handle. If not supplied, prints to screen
- `x::Array`:          string, date or array to print
- `width::Int`:        (keyword) scalar, minimum width of printed cells
- `prec::Int`:         (keyword) scalar, precision of printed cells
- `NoPrinting::Bool`:  (keyword) bool, true: no printing, just return formatted string
- `StringFmt::String`: (keyword) string, "", "html", "csv"

# Output
- str         (if NoPrinting) string, (otherwise nothing)

# Examples
```
x = [11 12;21 22]
printmat(x)
```
```
x = Any[1 "ab"; Date(2018,10,7) 3.14]
printmat(x,width=20)
```
Can also call as
```
opt = Dict(:width=>10,:prec=>3,:NoPrinting=>false,:StringFmt=>"")
printmat(x;opt...)     #notice , and ...
```
(not all keywords are needed)

# Requires
- Dates
- fmtNumPs

# To do


Paul.Soderlind@unisg.ch

"""
function printmat(fh::IO,x;width=10,prec=3,NoPrinting=false,StringFmt="")

  if isa(x,Union{String,Date,DateTime,Missing})  #eg. a single Date
    str = string(lpad(x,width),"\n")
    if NoPrinting
      return str
    else
      print(fh,str,"\n")
      return nothing
    end
  elseif isa(x,Nothing)
    return nothing
  end

  if ndims(x) > 2
    @warn("more than 2 dimensions")
    return nothing
  end

  (m,n) = (size(x,1),size(x,2))

  iob = IOBuffer()
  for i = 1:m                #loop over lines
    for j = 1:n-1                #loop over columns 1:n-1
      writeElementPs(iob,x,i,j,width,prec,StringFmt)
    end
    if StringFmt == "csv"                         #last (n) column
      writeElementPs(iob,x,i,n,width,prec,"")     #no , at end of line
    else
      writeElementPs(iob,x,i,n,width,prec,StringFmt)
    end
    write(iob,"\n")            #newline
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
printmat(x;width=10,prec=3,NoPrinting=false,StringFmt="") = printmat(stdout::IO,
         x,width=width,prec=prec,NoPrinting=NoPrinting,StringFmt=StringFmt)
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    printTable([fh::IO],x,colNames=[],rowNames=[];
               width=10,prec=3,NoPrinting=false,StringFmt="",cell00="")

Print formatted table with row names (1st column) column names (1st row),
and data matrix (the rest).


# Input
- `fh::IO`:            (optional) file handle. If not supplied, prints to screen
- `x::Array`:          (of numbers, dates, strings, ...) to print
- `colNames::Array`:   of strings with column headers
- `rowNames::Array`:   of strings with row labels
- `width::Int`:        (keyword) scalar, minimum width of printed cells. [10]
- `prec::Int`:         (keyword) scalar, precision of printed cells. [3]
- `NoPrinting::Bool`:  (keyword) bool, true: no printing, just return formatted string [false]
- `StringFmt::String`: (keyword) string, "", "html", "csv"
- `cell00::String`:    (keyword) string, for row 0, column 0

# Output
- `str::String`:      (if NoPrinting) string, (otherwise nothing)

# Example
```
xA = [1 "ab" "abc"; "ccc" 3.14 missing]
printTable(xA,colNames,["1";"4"],width=12,prec=2)
```
Can also call as
```
opt = Dict(:width=>10,:prec=>3,:NoPrinting=>false,:StringFmt=>"",:cell00=>"")
printTable(x;opt...)     #notice , and ...
```
(not all keywords are needed)

# Requires
- Dates
- printmat

"""
function printTable(fh::IO,x,colNames=[],rowNames=[];
                    width=10,prec=3,NoPrinting=false,StringFmt="",cell00="")

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

  iob = IOBuffer()
  if StringFmt == "html"                                             #print column names
    write(iob,"<tr><th>",lpad(cell00,rNamesWidth),"</th>")
    for i = 1:n
      write(iob,"<th>",lpad(colNames[i],width),"</th>")
    end
    write(iob,"</tr>")
  elseif StringFmt == "csv"
    write(iob,lpad(string(cell00,","),rNamesWidth))
    for i = 1:n-1
      write(iob,lpad(colNames[i],width),",")
    end
    write(iob,lpad(colNames[n],width))       #no , at line end
  else
    write(iob,lpad(cell00,rNamesWidth))                  #cell 0,0
    for i = 1:n                                          #create string
      write(iob,lpad(colNames[i],width))
    end
  end
  write(iob,"\n")

  xStr  = printmat(fh,x,width=width,prec=prec,NoPrinting=true,StringFmt=StringFmt)   #body of table, one long string
  xStrV = split(xStr,"\n")                       #vector of strings (one per row of x)

  for i = 1:m                           #loop over rows in x, print rowNames[i] and x[i,:]
    if StringFmt == "html"
      write(iob,"<tr><td><b>",rpad(rowNames[i],rNamesWidth),"</td></b>",xStrV[i],"</tr> \n")
    elseif StringFmt == "csv"
      write(iob,rpad(string(rowNames[i],","),rNamesWidth),xStrV[i],"\n")
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
printTable(x,colNames=[],rowNames=[];width=10,prec=3,NoPrinting=false,StringFmt="",cell00="") =
printTable(stdout::IO,x,colNames,rowNames,width=width,prec=prec,NoPrinting=NoPrinting,
                      StringFmt=StringFmt,cell00=cell00)
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    printlnPs([fh::IO],z...;width=10,prec=3)

Subsitute for println, with predefined formatting.


# Input
- `fh::IO`:    (optional) file handle. If not supplied, prints to screen
- `z::String`: string, numbers and arrays to print

Paul.Soderlind@unisg.ch

"""
function printlnPs(fh::IO,z...;width=10,prec=3)

  for x in z                              #loop over inputs in z...
    if isa(x,Union{String,Date,DateTime,Missing})
      print(fh,lpad(x,width))
    elseif isa(x,Nothing)
      print(fh,"")
    else                                         #other types
      iob = IOBuffer()
      for i = 1:length(x)
        if isa(x[i],AbstractFloat)               #Float
          write(iob,fmtNumPs(x[i],width,prec,"right"))
        elseif isa(x[i],Nothing)                 #Nothing
          write(iob,lpad("",width))
        else                                     #Integer, etc
          write(iob,lpad(x[i],width))
        end
      end
      print(fh,String(take!(iob)))
    end
  end

  print(fh,"\n")

end
                      #when fh is not supplied: printing to screen
printlnPs(z...;width=10,prec=3) = printlnPs(stdout::IO,z...,width=width,prec=prec)
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    printmat2

Call on printmat twice: to print to screen and then to an open file (IOStream)
"""
function printmat2(fh,x;width=10,prec=3,NoPrinting=false,StringFmt="")
  printmat(x,width=width,prec=prec,NoPrinting=NoPrinting,StringFmt=StringFmt)       #to screen
  if isa(fh,IOStream) && isopen(fh)
    printmat(fh,x,width=width,prec=prec,NoPrinting=NoPrinting,StringFmt=StringFmt)  #to file
  end
end
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    printTable2

Call on printTable2 twice: to print to screen and then to an open file (IOStream)
"""
function printTable2(fh,x,colNames=[],rowNames=[];width=10,prec=3,NoPrinting=false,
                     StringFmt="",cell00="")
  printTable(x,colNames,rowNames,width=width,prec=prec,NoPrinting=NoPrinting,
             StringFmt=StringFmt,cell00=cell00)      #to screen
  if isa(fh,IOStream) && isopen(fh)
    printTable(fh,x,colNames,rowNames,width=width,prec=prec,NoPrinting=NoPrinting,
               StringFmt=StringFmt,cell00=cell00) #to file
  end
end
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    println2Ps

Call on printlnPs twice: to print to screen and then to an open file (IOStream)
"""
function println2Ps(fh::IO,z...;width=10,prec=3)
  printlnPs(z...,width=width,prec=prec)              #to screen
  if isa(fh,IOStream) && isopen(fh)
    printlnPs(fh::IO,z...,width=width,prec=prec)     #to file
  end
end
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    writeElementPs(iob,x,i,j,width,prec,StringFmt)

Writes one element to iob, formatting depends on type
"""
function writeElementPs(iob,x,i,j,width,prec,StringFmt)

  if isa(x[i,j],AbstractFloat)         #Float
    write(iob,fmtNumPs(x[i,j],width,prec,"right",StringFmt))
  elseif isa(x[i,j],Union{Int,String}) #Int, String
    write(iob,fmtNumPs(x[i,j],width,0,"right",StringFmt))
  elseif isa(x[i,j],Bool)              #Bool, BitArrays, as 0/1, left
    write(iob,fmtNumPs(x[i,j]+0,width,0,"right",StringFmt))
  elseif isa(x[i,j],Nothing)           #Nothing, as ""
    write(iob,fmtNumPs("",width,0,"right",StringFmt))
  else                                 #other types (Missing,Date,...), right
    write(iob,fmtNumPs(x[i,j],width,0,"right",StringFmt))
  end

  return nothing
 end
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    fmtNumPs(z,width=10,prec=2,justify="right",StringFmt="")

Create a formatted string of a number. With prec=0, it can be used Bools and Strings



# Remark
- with prec=0, the function can be used for non-floats (incl. Bools and Strings)
- The Formatting.jl package provides more elegant solutions:
  fmt  = FormatSpec(string(">",width,".",prec,"f"))   #right justified, else "<"
  fmt  = FormatSpec(string(">",wid,"d"))              #for Int
  str  = Formatting.fmt(fmt1,z))

# Requires
- Dates

"""
function fmtNumPs(z,width=10,prec=2,justify="right",StringFmt="")

  if (prec > 0) && !ismissing(z) && !isnan(z)  && !isinf(z)  #example: 101.0234, prec=3
    (z_fract,z_int) = modf(abs(z))                     #0.02339999,101.0
    z_fractI = round(Int,exp10(prec)*z_fract)          #23
    z_fractS = lpad(z_fractI,prec,"0")                 #"023"
    z_intI   = round(Int,z_int)
    strLR    = string(z_intI,".",z_fractS)             #"101.023"
    (sign(z) < 0) && (strLR = string("-",strLR))       #fix sign, round(Int,) drops it
  else
    (isa(z,AbstractFloat) && !isnan(z) && !isinf(z)) && (z = round(Int,z))  #Float -> Int
    strLR = string(z)
  end

  if justify == "left"                            #justification
    strLR = rpad(strLR,width)
  else
    strLR = lpad(strLR,width)
  end

  if StringFmt == "html"                          #html or csv formatting
    strLR = string("<td>",strLR,"</td>")
  elseif StringFmt == "csv"
    strLR = string(strLR,",")
  end

  return strLR

end
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
function printblue(x...)
  foreach(z->printstyled(z,color=:blue,bold=true),x)
  print("\n")
end
function printred(x...)
  foreach(z->printstyled(z,color=:red,bold=true),x)
  print("\n")
end
function printmagenta(x...)
  foreach(z->printstyled(z,color=:magenta,bold=true),x)
  print("\n")
end
function printyellow(x...)
  foreach(z->printstyled(z,color=:yellow,bold=true),x)
  print("\n")
end
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
function printwhere(txt)
  println(@__FILE__," ",@__LINE__," ",txt)
end
#------------------------------------------------------------------------------

