#--------------------------------------------------------------------------------#
# Pedigree.jl
#--------------------------------------------------------------------------------#

module Pedigree

# load packages
using DataFrames
using Statistics
using StatsBase

# include functions
include("stack_ancestors.jl")
include("sort_ped.jl")
include("renum_ped.jl")
include("makeA.jl")
include("check_pedigree.jl")

# export function
export stack_ancestors
export sort_ped
export renum_ped
export makeA
export check_pedigree

end


