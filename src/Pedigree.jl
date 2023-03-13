#--------------------------------------------------------------------------------#
# Pedigree.jl
#--------------------------------------------------------------------------------#

module Pedigree

# load packages
using DataFrames

# include functions
include("stack_ancestors.jl")
include("sort_ped.jl")
include("renum_ped.jl")
include("makeA.jl")

# export function
export stack_ancestors
export sort_ped
export renum_ped
export makeA

end


