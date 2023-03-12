#--------------------------------------------------------------------------------#
# Pedigree.jl
#--------------------------------------------------------------------------------#

# start module
module Pedigree

# load packages
using DataFrames
using LinearAlgebra

# include functions
include("functions.jl")

# export function
export sort_ped
export renum_ped
export makeA

end



