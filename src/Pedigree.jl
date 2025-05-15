#--------------------------------------------------------------------------------#
# Pedigree.jl
#--------------------------------------------------------------------------------#

module Pedigree

# load necessary packages
using DataFrames

# include functions from other files in the package
include("stack_ancestors.jl")
include("sort_ped.jl")
include("renum_ped.jl")
include("makeA.jl")

# export functions for use outside the module
export stack_ancestors
export sort_ped
export renum_ped
export makeA

end # end of Pedigree module
