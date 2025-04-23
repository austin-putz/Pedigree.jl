#--------------------------------------------------------------------------------#
# sort_ped Function
#--------------------------------------------------------------------------------#

"""
    sort_ped(ped::DataFrame; maxrounds=1000)

Sort a pedigree in ancestral order, ensuring parents appear before their offspring.

This function sorts the pedigree so that all ancestors appear before their descendants.
It also adds any missing ancestors to the top of the pedigree with unknown parentage.

# Arguments
- `ped::DataFrame`: A DataFrame with at least 3 columns representing animal ID, sire ID, and dam ID.
- `maxrounds::Int=1000`: Maximum number of sorting iterations to perform before giving up.

# Returns
- `DataFrame`: A new DataFrame with the pedigree sorted in ancestral order.

# Examples
```julia
using DataFrames
using Pedigree

# Create a sample pedigree
ped = DataFrame(
    animal = ["A", "B", "C", "D"],
    sire = ["0", "0", "B", "B"],
    dam = ["0", "0", "A", "C"]
)

# Sort the pedigree
sorted_ped = sort_ped(ped)
```
"""
function sort_ped(ped::DataFrame; maxrounds=1000)

    # ped::DataFrame
    #       - pedigree with 1. animal (ID), 2. sire (father), 3. dam (mother)
    # maxrounds - default = 1000
    #       - specificies the max number of rounds to build the pedigree

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
	# Start pedigre with animals who are not parents
	#------------------------------------------------------------#

	# list unique parents
	parents = unique(vcat(ped[:, 2], ped[:, 3]))

	# remove parents that are "0" (missing)
	parents = filter(x -> x != "0", parents)

	# check to see if the animal (1st col) is in the list of parents
	# looking to find animals not in the pedigree as parents
	last_gen_index = in.(ped.animal, Ref(parents))

	# subset pedigree to those who are not parents ('new' pedigree)
	# this newped will be the sorted pedigree
	newped = ped[BitArray(1 .- last_gen_index), :]

	# remove these from the old pedigree 
	# will keep looking for parents in this pedigree as we delete them as 
	# they are added to the new sorted pedigree (newped)
	oldped = ped[last_gen_index, :]

	# set current pedigree
	# newped will be stacked each round with new parents
	# curped will be used to extract the parents of that generation of parents
	curped = newped
	
	# get number of animals in curped
	n_curped = size(curped, 1)

	# print number in current pedigree
	@info "  $n_curped non-parents added to the bottom of the pedigree to start"

	#------------------------------------------------------------#
	# Sort the pedigree
	#------------------------------------------------------------#

	# set round
	round = 1

	# here we need to loop over the pedigree to stack the parents on top of the last generation
	# Steps:
	# 	- We look at the current animals parents
	# 	- We get a unique list then check to see if those
	#     parents still exist in the old pedigree
	#   - We only add  these parents pedigree if they don't exist in the 'old' pedigree
	# 	- We then stack this on the new sorted pedigree
	# 	- We also delete them from the old pedigree
	# 	- Then we cycle through again, look at the parents of those parents,
	#     checking if they exist in the old pedigree, stack them on the new pedigree
	while size(oldped, 1) > 0

		# end if it hits too many rounds
		if round > maxrounds
			error("\nHit maximum number of rounds\n")
		end

		# get unique parents in current pedigree
		parents = unique(vcat(curped[:, 2], curped[:, 3]))

		# remove parents that are = "0" (missing)
		parents = filter(x -> x != "0", parents)

		# find parents in old pedigree
		parents_old = unique(vcat(oldped[:, 2], oldped[:, 3]))
		parents_old = filter(x -> x != "0", parents_old)

		# find these new parents in old pedigree (deleting as we go)
		index_old_parents = BitArray(1 .- in.(parents, Ref(parents_old)))

		# get list of parents that are not in the old pedigree as parents still
		list_parent_not_in_ped = parents[index_old_parents]

		# subset old pedigree to youngest parents - current pedigree
		curped = oldped[in.(oldped.animal, Ref(list_parent_not_in_ped)), :]

		# get number of animals in curped
		n_curped = size(curped, 1)

		# print number in current pedigree
		@info "  $n_curped parents added this round"

		# stack on new pedigree (make sure they go on top)
		newped = vcat(curped, newped)

		# delete these animals from the old pedigree
		oldped = oldped[BitArray(1 .- in.(oldped.animal, Ref(list_parent_not_in_ped))), :]

		# increase round by 1
		round = round + 1

	end

	#------------------------------------------------------------#
	# Stack Ancestors
	#------------------------------------------------------------#

	# print number of rounds
	@info "Took $round rounds to build the pedigree"

	# get unique parents
	parents = unique(vcat(newped[:, 2], newped[:, 3]))

	# remove parents that are "0"
	parents = filter(x -> x != "0", parents)

	# test which parents are not in pedigree
	ancestor_index = BitArray(1 .- in.(parents, Ref(newped[:, 1])))

	# subset parents vector to only ancestors (are not in pedigree)
	ancestors = parents[ancestor_index]

	# add missing parents as ancestors
	ped_ancestors = DataFrame(animal = ancestors, sire="0", dam="0")

	# get number of ancestors
	n_ancestors = size(ped_ancestors, 1)

	# print number of ancestors
	@info "  $n_ancestors ancestors added to the top of the pedigree"

	# concat ancestors on top of sorted pedigree
	newped = vcat(ped_ancestors, newped)

	#------------------------------------------------------------#
	# Return
	#------------------------------------------------------------#

	# return sorted pedigree
	return newped

end

