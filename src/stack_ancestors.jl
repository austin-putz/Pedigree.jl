#--------------------------------------------------------------------------------#
# stack_ancestors Function
#--------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------#
# Description
#--------------------------------------------------------------------------------#

# Here I need to stack ancestors (parents) on top of the pedigree that are not
# in the pedigree. 

#--------------------------------------------------------------------------------#
# Main Function
#--------------------------------------------------------------------------------#

"""
    stack_ancestors(ped::DataFrame)

Add missing ancestors to the pedigree.

This function finds all individuals that appear as parents but are not present in
the pedigree as individuals. These missing ancestors are added to the top of the
pedigree with unknown parentage (sire and dam set to "0").

# Arguments
- `ped::DataFrame`: A DataFrame with at least 3 columns representing animal ID, sire ID, and dam ID.

# Returns
- `DataFrame`: A new DataFrame with ancestors added at the top, with each row containing an animal ID and its parents.

# Examples
```julia
using DataFrames
using Pedigree

# Create a simple pedigree
ped = DataFrame(
    animal = ["A", "B", "C"],
    sire = ["X", "0", "B"],
    dam = ["Y", "0", "A"]
)

# Stack missing ancestors
stacked_ped = stack_ancestors(ped)
```

In this example, "X" and "Y" would be added to the pedigree with "0" as their parents.
"""
function stack_ancestors(ped::DataFrame)

	#------------------------------------------------------------#
	# Setup Ped
	#------------------------------------------------------------#

	# extract first 3 columns
	ped = ped[:, 1:3]

	# rename columns: 1. animal, 2. sire, 3. dam
	rename!(ped, [:animal, :sire, :dam])

	#------------------------------------------------------------#
	# Check Pedigree
	#------------------------------------------------------------#

	# Test if the ped is a DataFrame
	if (typeof(ped) == DataFrame)
		@info "Pedigree is a DataFrame"
	else
		error("Pedigree needs to be a DataFrame")
	end

	# check to make sure each column is a String
	if (eltype(ped.animal) != String)
		@info "Need the pedigree to be a string, will convert animal to String"
		ped.animal = string.(ped.animal)
	end
	if (eltype(ped.sire) != String)
		@info "Need the pedigree to be a string, will convert sire to String"
		ped.sire = string.(ped.sire)
	end
	if (eltype(ped.dam) != String)
		@info "Need the pedigree to be a string, will convert dam to String"
		ped.dam = string.(ped.dam)
	end

	#------------------------------------------------------------#
	# Stack Ancestors
	#------------------------------------------------------------#

	# get unique parents
	parents = unique(vcat(ped[:, 2], ped[:, 3]))

	# remove parents that are "0"
	parents = filter(x -> x != "0", parents)

	# test which parents are not in pedigree
	ancestor_index = BitArray(1 .- in.(parents, Ref(ped[:, 1])))

	# subset parents vector to only ancestors (are not in pedigree)
	ancestors = parents[ancestor_index]

	# add missing parents as ancestors
	ped_ancestors = DataFrame(animal = ancestors, sire="0", dam="0")

	# number of ancestors to print later
	n_ancestors = size(ancestors, 1)

	# print message
	@info "Found $n_ancestors ancestors (stacking on top of the pedigree)"

	# concat ancestors on top of sorted pedigree
	ped = vcat(ped_ancestors, ped)

	#------------------------------------------------------------#
	# Return
	#------------------------------------------------------------#

	# return sorted pedigree
	return ped
	
end


