function printmat(x,width=10,prec=3,Numfmt=NaN,NoPrinting=false)
#printmat   Prints all elements of matrix with a predefined formatting.
#
#
#
#  Input:      x           numerical matrix to print
#              width       (optional) scalar, width of printed cells. [10]
#              prec        (optional) scalar, precision of printed cells. []
#              Numfmt      dummy argument, not used
#              NoPrinting  (optional) bool, true: no printing, just return formatted string
#
#  Output:     str         (if NoPrinting) string, (otherwise nothing)
#
#
#  Uses:      fmtNumPs
#
#
#  Paul.Soderlind@unisg.ch, May 2017
#------------------------------------------------------------------------------

  if typeof(x) <: String                      #strings need special treatment
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
    for i = 1:m
      for j = 1:n
        if fmt2a == "f"
          s = s * fmtNumPs(x[i,j,k],width,prec,"right")
        elseif fmt2a == "d"
          s = s * fmtNumPs(x[i,j,k],width,0,"right")
        else
          s = s * lpad(x[i,j,k],width)
        end
      end
      s = s * "\n"            #newline at end of row
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
function set_printlnPsOpt(opt)    #This function is needed if printlnPs
   global printlnPsOpt            #is part of a module. Otherwise we could
   printlnPsOpt = opt             #set printlnPsOpt directly.
   println("printlnPsOpt is now $printlnPsOpt")
end
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
function printlnPs(z...)
#printlnPs   Subsitute for println by predefined formatting.
#
#
#  Input:      z           string, numbers and arrays to print
#
# Refers to:   printlnPsOpt, global, Dict("width"=>10,"prec"=>3)
#
#              The formatting can be set globally by defining a dictionary
#              called in the calling scope.
#
#
#  Paul.Soderlind@unisg.ch, Jan 2017
#------------------------------------------------------------------------------

  global printlnPsOpt

  if isdefined(:printlnPsOpt)                   #getting defaults from dictionary
    width  = get(printlnPsOpt,"width",10)
    prec   = get(printlnPsOpt,"prec",3)
  else                                              #setting defaults inside fn
    width  = 10
    prec   = 3
  end

  for x in z                              #loop over inputs in z...
    if typeof(x) <: String                      #plain string, no array of strings
      print(x)
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
function println4Ps(width,prec,z...)
#printlnPs   Subsitute for println by formatting of width and precision
#
#
#  Input:      z           string, numbers and arrays to print
#
#
#
#  Paul.Soderlind@unisg.ch, May 2017
#------------------------------------------------------------------------------

  for x in z                              #loop over inputs in z...
    if typeof(x) <: String                      #plain string, no array of strings
      print(x)
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
