function readdlmFixPs(x,missVal=NaN)
#readdlmFixPs    Change from " " to missVal (defaults to NaN) in arrays
#                imported by readdlm and then convert to float
#
#  Usage:    readdlmFixPs(x[,missVal])
#
#  Input:    x         TxK heterogeneous matrix with some missing values "  "
#            missVal   scalar, to replace missing values in X with
#
#  Output:   y         TxK matrix
#
#
#  Paul.Soderlind@unisg.ch
#------------------------------------------------------------------------------

  y = copy(x)
  for i in eachindex(x)
    if !isa(x[i],Number)
      y[i] = missVal
    end
  end

  y = convert(Array{Float64},y)        #convert to float

  return y

end
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
function readdlmFixPs!(x,missVal=NaN)
#readdlmFixPs    Change from " " to missVal (defaults to NaN) in arrays
#                imported by readdlm and then convert to float. Overwrites input.
#                Must call as x = readdlmFixPs!(x) due to convert.
#
#
#
#
#  Usage:    readdlmFixPs!(x[,missVal])
#
#  Input:    x         TxK heterogeneous matrix with some missing values "  "
#            missVal   scalar, to replace missing values in X with
#
#  Output:   y         TxK matrix
#
#
#
#
#
#
#  Paul.Soderlind@unisg.ch
#------------------------------------------------------------------------------

  for i in eachindex(x)
    if !isa(x[i],Number)
      x[i] = missVal            #overwriting old x
    end
  end

  x = convert(Array{Float64},x)   #convert to float

  return x

end
#------------------------------------------------------------------------------
