#------------------------------------------------------------------------------
"""
    printmat([fh::IO],x,width=10,prec=3,NoPrinting=false,htmlQ=false)

Prints all elements of matrix with a predefined formatting.

# Input
- `fh::IO`:           (optional) file handle. If not supplied, prints to screen
- `x::Array`:         string, date or array to print
- `width::Int`:       (optional) scalar, width of printed cells. [10]
- `prec::Int`:        (optional) scalar, precision of printed cells. []
- `NoPrinting::Bool`: (optional) bool, true: no printing, just return formatted string
- `hmtlQ::Bool`:      (optional) bool, true: format as htmlQ <td>cells</td>

# Output
- str         (if NoPrinting) string, (otherwise nothing)

# Uses
- fmtNumPs

# To do
- skip input ,DateFmt="yyyy-mm-dd"?
- sort out dispatch and keyword arguments


Paul.Soderlind@unisg.ch

"""
function printmat(fh::IO,x,width=10,prec=3,NoPrinting=false,htmlQ=false)

  if typeof(x) <: String || typeof(x) <: Union{Date,DateTime}    #strings,DateTime need special treatment
    str = string(x,"\n")
    if NoPrinting
      return str
    else
      print(fh,str,"\n")
      return nothing
    end
  end

  if ndims(x) > 2
    @warn("more than 2 dimensions")
    return nothing
  end

  (m,n) = (size(x,1),size(x,2))

  iob = IOBuffer()
  for i = 1:m                #loop over lines
    for j = 1:n                #loop over columns
      if typeof(x[i,j]) <: AbstractFloat                    #Floats,NaN
        write(iob,fmtNumPs(x[i,j],width,prec,"right",htmlQ))
      elseif typeof(x[i,j]) <:Union{Integer,Missing}        #Signed,Unsigned,BigInt,Missing
        write(iob,fmtNumPs(x[i,j],width,0,"right",htmlQ))
      else
        htmlQ ? write(iob,"<td>",lpad(x[i,j],width),"</td>") : write(iob,lpad(x[i,j],width))
      end
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
printmat(x,width=10,prec=3,NoPrinting=false,htmlQ=false) = printmat(stdout::IO,
         x,width,prec,NoPrinting,htmlQ)
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    fmtNumPs(z,width=10,prec=2,justify="right",htmlQ=false)

Formats a scalar and creates a string of it.

"""
function fmtNumPs(z,width=10,prec=2,justify="right",htmlQ=false)
  if prec > 0                        #if decimal number
    z   = round(z,digits=prec)       #101.23
    str = split(string(z),'.')
    if length(str) > 1
      strR  = string(".",rpad(str[2],prec,"0"))   #.23
      strLR = string(str[1],strR)                 #"101" * ".23"
    else                                          #eg. NaN, missing
      strLR = string(z)
    end
  else
    if typeof(z) <: AbstractFloat                  #Floats
      z = round(Int,z)
    end
    strLR = string(z)
  end
  if justify == "left"
    strLR = rpad(strLR,width)
  else
    strLR = lpad(strLR,width)
  end
  htmlQ && (strLR = string("<td>",strLR,"</td>"))
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

# Notice
This function is needed if printlnPs is part of a module.
Otherwise we could set printlnPsOpt directly.

"""
function set_printlnPsOpt(opt)
   global printlnPsOpt
   printlnPsOpt = opt
   println("printlnPsOpt is now $printlnPsOpt")
end
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    printlnPs([fh::IO],z...)

Subsitute for println, with predefined formatting.


# Input
- `fh::IO`:    (optional) file handle. If not supplied, prints to screen
- `z::String`: string, numbers and arrays to print

# Refers to
- printlnPsOpt, a global Dict("width"=>10,"prec"=>3)

The formatting can be set globally by defining a dictionary in the calling scope.

Paul.Soderlind@unisg.ch, Jan 2017

"""
function printlnPs(fh::IO,z...)

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
      print(fh,x)
    elseif typeof(x) <: Union{Date,DateTime}
      print(fh,rpad(x,width))
    else
      iob = IOBuffer()                     #opening IOBuffer
      for i = 1:length(x)
        eltype_x = eltype(x[i])
        if eltype_x <: Union{AbstractFloat,Missing}
          write(iob,fmtNumPs(x[i],width,prec,"right"))
        elseif eltype_x <: Union{Integer,Missing}
          write(iob,fmtNumPs(x[i],width,0,"right"))
        else
          write(iob,lpad(x[i],width))
        end
      end
      print(fh,String(take!(iob)))
    end
  end

  print(fh,"\n")

end
                      #when fh is not supplied: printing to screen
printlnPs(z...) = printlnPs(stdout::IO,z...)
#------------------------------------------------------------------------------
