#------------------------------------------------------------------------------
"""
    printmat(x,width,prec=3,Numfmt=NaN,NoPrinting=false)

Prints all elements of matrix with a predefined formatting.

# Input
- `x::Array`:         string, date or array to print
- `width::Int`:       (optional) scalar, width of printed cells. [10]
- `prec::Int`:        (optional) scalar, precision of printed cells. []
- `Numfmt`:           dummy argument, not used
- `NoPrinting::Bool`:  (optional) bool, true: no printing, just return formatted string

# Output
- str         (if NoPrinting) string, (otherwise nothing)

# Uses
- fmtNumPs

Paul.Soderlind@unisg.ch, May 2017

"""
function printmat(x,width=10,prec=3,Numfmt=NaN,NoPrinting=false)

  if typeof(x) <: String || typeof(x) <: Union{Date,DateTime}    #strings,DateTime need special treatment
    str = string(x,"\n")
    if NoPrinting
      return str
    else
      println(str)
      return nothing
    end
  end

  numdims = ndims(x)

  if numdims > 3
    warn("$numdims > 3")
    return nothing
  end

  eltype_x = eltype(x)
  if eltype_x <: AbstractFloat
    fmt2a = "f"
  elseif eltype_x <: Signed || eltype_x <: Unsigned || eltype_x <: BigInt
    fmt2a = "d"
  elseif eltype_x <: Bool
    fmt2a = "s"
  else
    fmt2a = "s"      #assume strings
  end

  (m,n,p) = size(x,1,2,3)

  str = ""
  for k = 1:p                          #loop over dim 3
    s = ""
    if p > 1
      s = s * "x[:,:,$k]\n"
    end
    for i = 1:m                #loop over lines
      for j = 1:n                #loop over columns
        if fmt2a == "f"
          s = s * fmtNumPs(x[i,j,k],width,prec,"right")
        elseif fmt2a == "d"
          s = s * fmtNumPs(x[i,j,k],width,0,"right")
        else
          s = s * lpad(x[i,j,k],width)
        end
      end
      s = s * "\n"            #newline at end of line
    end
    str = str * s
  end

  if NoPrinting                              #no printing, just return str
    return str
  else                                       #print, return nothing
    println(str)
    return nothing
  end

end
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    fmtNumPs(z,width=10,prec=2,justify="right")

Formats a scalar and creates a string of it.

"""
function fmtNumPs(z,width=10,prec=2,justify="right")
  if prec > 0                        #if decimal number
    z     = round(z,prec)            #101.23
    str   = split(string(z),'.')
    if length(str) > 1
      strR = string(".",rpad(str[2],prec,0))   #.23
      strLR = string(str[1],strR)              #"101" * ".23"
    else                                       #eg. NaN
      strLR = string(z)
    end
  else                               #if integer
    z     = round(Int,z)
    strLR = string(z)
  end
  if justify == "left"
    strLR = rpad(strLR,width)
  else
    strLR = lpad(strLR,width)
  end
  return strLR
end
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
global printlnPsOpt = Dict("width"=>10,"prec"=>3)    #options for printlnPs()
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    set_printlnPsOpt(opt)

Set global options (width and prec) to printlnPs.

"""
function set_printlnPsOpt(opt)    #This function is needed if printlnPs
   global printlnPsOpt            #is part of a module. Otherwise we could
   printlnPsOpt = opt             #set printlnPsOpt directly.
   println("printlnPsOpt is now $printlnPsOpt")
end
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    printlnPs(z...)

Subsitute for println by predefined formatting.


# Input
- `z::String`: string, numbers and arrays to print

# Refers to
- printlnPsOpt, a global Dict("width"=>10,"prec"=>3)

The formatting can be set globally by defining a dictionary
             in the calling scope.

Paul.Soderlind@unisg.ch, Jan 2017

"""
function printlnPs(z...)

  global printlnPsOpt

  width = try                    #getting defaults from dictionary
    get(printlnPsOpt,"width",10)
  catch                          #if Dict() printlnPsOpt is not defined
    10
  end
  prec = try
    get(printlnPsOpt,"prec",3)
  catch
    3
  end

  for x in z                              #loop over inputs in z...
    if typeof(x) <: String
      print(x)
    elseif typeof(x) <: Union{Date,DateTime}
      print(rpad(x,width))
    else
      eltype_x = eltype(x)
      m = length(x)
      s = ""
      for i = 1:m
        if eltype_x <: AbstractFloat
          s = s * fmtNumPs(x[i],width,prec,"right")
        elseif eltype_x <: Signed || eltype_x <: Unsigned || eltype_x <: BigInt
          s = s * fmtNumPs(x[i],width,0,"right")
        elseif eltype_x <: Bool
          s = s * lpad(x[i],width)
        else
          s = s * lpad(x[i],width)
        end
      end
      print(s)
    end
  end

  print("\n")

end
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    println4Ps(width,prec,z...)

Subsitute for println by formatting of width and precision


# Input
- `z::String`:   string, numbers and arrays to print



Paul.Soderlind@unisg.ch, May 2017

"""
function println4Ps(width,prec,z...)

  for x in z                              #loop over inputs in z...
    if typeof(x) <: String
      print(x)
    elseif typeof(x) <: Union{Date,DateTime}
      print(rpad(x,width))
    else
      eltype_x = eltype(x)
      m = length(x)
      s = ""
      for i = 1:m
        if eltype_x <: AbstractFloat
          s = s * fmtNumPs(x[i],width,prec,"right")
        elseif eltype_x <: Signed || eltype_x <: Unsigned || eltype_x <: BigInt
          s = s * fmtNumPs(x[i],width,0,"right")
        elseif eltype_x <: Bool
          s = s * lpad(x[i],width)
        else
          s = s * lpad(x[i],width)
        end
      end
      print(s)
    end
  end

  print("\n")

end
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    printmatDate(dN,x,DateFmt="yyyy-mm-dd",width=10,prec=3)

Print formatted dates (1st column) and data matrix (remaining colums).

See Dates.format() for the DateFmt and printmat() for (width,prec)

"""
function printmatDate(dN,x,DateFmt="yyyy-mm-dd",width=10,prec=3)

  dNStr = Dates.format.(dN,DateFmt)            #vector of strings
  T     = length(dNStr)

  xStr  = printmat(x,width,prec,NaN,true)      #one long string
  xStrV = split(xStr,"\n")                     #vector of strings (one element per line)

  Str = Array{String}(T)                       #concatenate line by line
  for i = 1:T
    Str[i] = join([dNStr[i],xStrV[i],"\n"])
  end
  Str = join(Str)                              #join into one long string

  printmat(Str,width,prec)

end
#------------------------------------------------------------------------------
