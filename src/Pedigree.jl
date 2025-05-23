#--------------------------------------------------------------------------------#
# Pedigree.jl
#--------------------------------------------------------------------------------#

module Pedigree

# load necessary packages
using DataFrames
using Statistics
using StatsBase

# include functions from other files in the package
include("stack_ancestors.jl")
include("sort_ped.jl")
include("renum_ped.jl")
include("make_A.jl")
include("check_pedigree.jl")
include("find_duplicates.jl")

# export functions for use outside the module
export stack_ancestors
export sort_ped
export renum_ped
export make_A
export check_pedigree
export find_duplicates

end # end of Pedigree module
