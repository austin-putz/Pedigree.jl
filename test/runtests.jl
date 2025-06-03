
# load libraries
using Pkg
using Test
using Pedigree
using DataFrames
using Random

# make test pedigree
ped = DataFrames.DataFrame( 
		animal = ["G", "E", "K", "I", "C", "D", "L", "F", "J", "H"], 
		sire   = ["A", "A", "H", "A", "A", "A", "A", "A", "H", "F"], 
		dam    = ["D", "0", "I", "C", "B", "B", "J", "C", "I", "D"]
	)

# shuffle the pedigree
Random.shuffle!(ped)

# stack ancestors
stack_ancestors(ped)

# sort the pedigree
ped_sort = Pedigree.sort_ped(ped)

# renumber the pedigree
ped_renum = Pedigree.renum_ped(ped_sort)

# make A
A = Pedigree.make_A(ped_renum)










