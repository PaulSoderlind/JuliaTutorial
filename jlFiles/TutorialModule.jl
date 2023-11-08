module TutorialModule

import Printf                                         #the module can use other packages
#import LinearAlgebra

export printmat, printlnPs, printblue, printTeXTable  #available after `using .TutorialModule`

include("printmat.jl")                                #files with the functions
include("printTeXTable.jl")                           #could also type in the code here

end
