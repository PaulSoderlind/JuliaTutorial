#------------------------------------------------------------------------------
function printmat(x,NoPrinting=false)
#printmat   Prints all elements of matrix with hard coded formatting.
#
##
#  Input:      x           numerical matrix to print
#              NoPrinting  (optional) bool, true: no printing, just return formatted string
#
#  Output:     str         (if NoPrinting) string, (otherwise nothing)
#
#
#  Paul.Soderlind@unisg.ch, Jan 2017
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

  (m,n,p) = size(x,1,2,3)

  str = ""
  for k = 1:p                          #loop over dim 3
    s = ""
    if p > 1
      s = s * "x[:,:,$k]\n"
    end
    for i = 1:m
      for j = 1:n
        if eltype_x <: AbstractFloat
          s = s * @sprintf("%10.3f",x[i,j,k])
        elseif eltype_x <: Signed || eltype_x <: Unsigned || eltype_x <: BigInt
          s = s * @sprintf("%10.0f",x[i,j,k])
        elseif eltype_x <: Bool
          s = s * @sprintf("%10s",x[i,j,k])
        else
          s = s * @sprintf("%10s",x[i,j,k])
        end
      end
      s = s * @sprintf("%s\n","")
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
function printlnPs(z...)
#printlnPs   Subsitute for println by hard coded formatting.
#
#
#  Input:      z           string, numbers and arrays to print
#
#
#  Paul.Soderlind@unisg.ch, Jan 2017
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
          s = s * @sprintf("%10.3f",x[i])
        elseif eltype_x <: Signed || eltype_x <: Unsigned || eltype_x <: BigInt
          s = s * @sprintf("%10.0f",x[i])
        elseif eltype_x <: Bool
          s = s * @sprintf("%10s",x[i])
        else
          s = s * @sprintf("%10s",x[i])
        end
      end
      print(s)
    end
  end

  print("\n")

end
#------------------------------------------------------------------------------
