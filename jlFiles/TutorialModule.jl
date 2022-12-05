module TutorialModule

using Printf                       #the module can use other packages
#import LinearAlgebra

export printmat, printlnPs, printblue, printTeXTable   #available after `using TutorialModule`

include("printmat.jl")                                 #code
include("printTeXTable.jl")

end
