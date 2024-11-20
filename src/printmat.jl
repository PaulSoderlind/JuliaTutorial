#------------------------------------------------------------------------------
"""
    printmat([fh::IO],x...;colNames=[],rowNames=[],
             width=10,prec=3,NoPrinting=false,StringFmt="",cell00="",colUnderlineQ=false)

Print all elements of a matrix (or several) with predefined formatting. It can also handle
OffsetArrays and Tables (from Tables.jl). StringFmt = "csv" prints using a csv format.
The `colNames` for Tables default to the `Tables.columnnames()`.

# Input
- `fh::IO`:            (optional) file handle. If not supplied, prints to screen
- `x::Array(s) or Tables`:  (of numbers, dates, strings, ...) to print
- `colNames::Array`:     of strings with column headers, alternatively like "c" to get "c1,c2,..."
- `rowNames::Array`:     of strings with row labels, alternatively like "r" to get "r1,r2,..."
- `width::Int`:          (keyword) minimum width of printed cells
- `prec::Int`:           (keyword) precision of printed cells (number of digits after .)
- `NoPrinting::Bool`:    (keyword) if true: no printing, just return formatted string [false]
- `StringFmt::String`:   (keyword) "csv" to create a csv formatted string, otherwise ""
- `cell00::String`:      (keyword) text for row 0, column 0
- `colUnderlineQ::Bool`: (keyword) if true: column names are underlined

# Output
- str         (if NoPrinting) string, (otherwise nothing)

# Examples
```
x = [11 12;21 22]
printmat(x)
```
```
x = [1 "ab"; Date(2018,10,7) 3.14]
printmat(x;width=20,colNames=["col 1","col 2"])
```
```
printmat([11,12],[21,22])
```
Can also call as
```
opt = Dict(:rowNames=>["1";"4"],:width=>10,:prec=>3,:NoPrinting=>false,:StringFmt=>"")
printmat(x;colNames=["a","b"],opt...)     #notice ; and ...
```
(not all keywords are needed)

# Requires
- Printf
- (the functions fmtNumPs,table_to_matrix,hcatWithTypePs(x...) are further down in this file)

# Notice
- For Tables.table, the Tables.columnnames() are used for colNames (if they exist and colNames=[])
- The code is not optimized for speed. I just aims to be fairly simple and get the job done.

Paul.Soderlind@unisg.ch

"""
function printmat(fh::IO,x...;colNames=String[],rowNames=String[],
                  width=10,prec=3,NoPrinting=false,StringFmt="",cell00="",colUnderlineQ=false)

  isempty(x) && return nothing                         #do nothing if isempty(x)

  delim = StringFmt == "csv" ? "," : ""                #delimiter between cells

  if isdefined(Main,:Tables) && any(Tables.istable,x)  #use only if Tables.jl is loaded && x contains Table
    xx = ntuple(i->table_to_matrix(x[i]),length(x))
    (x,x_names) = (getindex.(xx,1),getindex.(xx,2))    #unpack into 2 n-tuples
    (isempty(colNames) && all(!isempty,x_names)) && (colNames = vcat(x_names...)) #use Tables.columnnames
  end

  x     = hcatWithTypePs(x...)     #create matrix as in hcat(x...), but defaulting to Any if eltypes differ
  (m,n) = (size(x,1),size(x,2))    #hcat(x...) also converts OffsetArrays to tradional arrays

  colNames = ExpandrcNamesPs(colNames,n)            #(a) if non-empty, single string to Vector;
  rowNames = ExpandrcNamesPs(rowNames,m)            #(b) if non-empty, to n-vector with numbers

  cell00    = isempty(rowNames) ? "" : cell00                                 #force cell00="" if no rowNames
  col0Width = isempty(rowNames) ? 0  : maximum(length,vcat(cell00,rowNames))  #width of column 0 (cell00 and rowNames)
  colWidth  = fill(width,n)                                                   #widths of column 1:n

  iob = IOBuffer()

  if isa(colNames,Vector) && (length(colNames)==n)                            #if there are column names
    colNamesPrint(iob,colNames,n,cell00,col0Width,colWidth,delim)
    colUnderlineQ && colNamesPrint(iob,colNames,n,cell00,col0Width,colWidth,delim,true)
  end

  aLine = fill("",1+n)
  isempty(rowNames) && (rowNames = fill("",m))        #empty rowNames, if needed
  for i = 1:m                                         #print each line: [rowName[i] x[i,:]]
    aLine .= ""                                       #reset the line to empty
    aLine[1] = rpad(rowNames[i],col0Width)
    for j = 1:n                         #loop over columns
      aLine[1+j] = fmtNumPs(x[i,j],width,prec,"right")
    end
    col0Width == 0 ? join(iob,view(aLine,2:1+n),delim) : join(iob,aLine,delim)
    print(iob,"\n")
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
printmat(x...;colNames=String[],rowNames=String[],width=10,prec=3,NoPrinting=false,StringFmt="",cell00="",colUnderlineQ=false) =
    printmat(stdout::IO,x...;colNames,rowNames,width,prec,NoPrinting,StringFmt,cell00,colUnderlineQ)
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
    if isa(x,AbstractArray)
      iob = IOBuffer()
      for x_i in x
        print(iob,fmtNumPs(x_i,width,prec,"right"))
      end
      print(fh,String(take!(iob)))
    else
      print(fh,fmtNumPs(x,width,prec,"right"))
    end
  end

  print(fh,"\n")

end
                      #when fh is not supplied: printing to screen
printlnPs(z...;width=10,prec=3) = printlnPs(stdout::IO,z...;width,prec)
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    fmtNumPs(z,width=10,prec=2,justify="right")

Create a formatted string of a float (eg, "%10.4f"), nothing (""),
while other values are passed through. Strings are right (or left) justified.

# Notice
- With prec > 0 and isa(z,Integer), then the string is padded with 1+prec spaces
to align with the printing of floats with the same prec.

# Requires
- Printf

"""
function fmtNumPs(z,width=10,prec=2,justify="right")

  isa(z,Bool) && (z = convert(Int,z))             #Bool -> Int

  if isa(z,AbstractFloat)                         #example: 101.0234, prec=3
    fmt   = Printf.Format("%$(width).$(prec)f")
    strLR = Printf.format(fmt,z)
  elseif isa(z,Nothing)
    strLR = ""
  elseif isa(z,Integer) && prec > 0               #integer followed by (1+prec spaces)
    strLR = string(z,repeat(" ",1+prec))
  else                                            #Int, String, Date, Missing, etc
    strLR = string(z)
  end
                                                #justification
  strLR = justify == "left" ? rpad(strLR,width) : lpad(strLR,width)

  return strLR

end
#---------------------------------------------------s---------------------------


##------------------------------------------------------------------------------
"""
    hcatWithTypePs(x...)

Does hcat(x...), but defaults to an `Any` matrix if the `eltype`s
differ across `x[i]`. Otherwise, a standard `hcat(x...)`

"""
function hcatWithTypePs(x...)
  typeTestQ = any(!=(eltype(x[1])),eltype.(x))  #test if eltype(x[i]) differs
  if typeTestQ                                      #create matrix from tuple created by x...
    x = hcat(convert(Array{Any},hcat(x[1])),x[2:end]...)   #preserving types of x[i]
  else                                                     #hcat(x[1]) to guarantee a matrix
    x = hcat(x...)
  end
  return x
end
##------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    table_to_matrix(tab)

Help function to facilitate printing of a Tables.table. The function creates a matrix from
a row or column table, and also extract the column names. If `tab` is an array, then it is
just copied.

"""
function table_to_matrix(tab)
  if Tables.istable(tab)
    x_mat   = Tables.matrix(tab)                           #create matrix
    x_names = Tables.isrowtable(tab) ? "" : string.(Tables.columnnames(tab))
  else
    x_mat   = tab                                          #for an array: just copy
    x_names = ""
  end
  return x_mat, x_names
end
#------------------------------------------------------------------------------


##------------------------------------------------------------------------------
"""
    ExpandrcNamesPs(rcNames,n)

Expand "abc" to ["abc"] (leaving ["def"] and "" untouched) and then also create
a vector of ["def1","def2",...,"defn"] (or similarly for any non-empty string)

"""
function ExpandrcNamesPs(rcNames,n)
  if isa(rcNames,String) && !isempty(rcNames)           #"abc" to ["abc"], but leave "" untouched
    rcNames = [rcNames]
  end
  if length(rcNames) == 1 < n
    rcNames = string.(only(rcNames),1:n)                #create "ci" from ["c"] for i=1:n
  end
  return rcNames
end
##------------------------------------------------------------------------------


##------------------------------------------------------------------------------
"""


"""
function colNamesPrint(iob,colNames,n,cell00,col0Width,colWidth,delim="",DoUnderline=false)
  aLine = fill("",1+n)                                         #intermediate storage
  aLine[1] = DoUnderline ? rpad(repeat("¯",length(cell00)),col0Width) :
                           rpad(cell00,col0Width)
  for j = 1:n                                                #loop over columns
    aLine[1+j] = DoUnderline ? lpad(repeat("¯",length(colNames[j])),colWidth[j]) :
                               lpad(colNames[j],colWidth[j])
  end
  aString = col0Width == 0 ? join(view(aLine,2:1+n),delim) : join(aLine,delim)  #join into string
  print(iob,aString,"\n")
  return nothing
end
##------------------------------------------------------------------------------


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
"""
    doc2(fn)

Macro to display the documentation of a function or other object.
Call it as `@doc2 printmat`. For use in notebooks in VS code.
(In most other cases `@doc printmat` works well.)

"""
macro doc2(fn)
  return :( display("text/markdown",Base.doc($(esc(fn)))))
end
#------------------------------------------------------------------------------
