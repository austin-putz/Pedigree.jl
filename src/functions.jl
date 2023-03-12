#--------------------------------------------------------------------------------#
# functions.jl
#--------------------------------------------------------------------------------#

# Here are the functions for Pedigree.jl

# List of functions contained:
#   - sort_ped()
#   - renum_ped()
#   - makeA() 
#   - 




#--------------------------------------------------------------------------------#
# sort_ped() Function
#--------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------#
# Description
#--------------------------------------------------------------------------------#

# this function takes a Pedigree that has columns 1. animal, 2. sire, 3. dam
# 

#--------------------------------------------------------------------------------#
# Function
#--------------------------------------------------------------------------------#

# write function
function sort_ped(ped::DataFrame; maxrounds=1000)

    # ped::DataFrame
    #       - pedigree with columns
    #            1. animal (ID)
    #            2. sire (father)
    #            3. dam (mother)
    # maxrounds::Int64
    #       - default = 1000
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

		# subset old pedigree
		curped = oldped[in.(oldped.animal, Ref(list_parent_not_in_ped)), :]

		# stack on new pedigree (make sure they go on top)
		newped = vcat(curped, newped)

		# delete these animals from the old pedigree
		oldped = oldped[BitArray(1 .- in.(oldped.animal, Ref(list_parent_not_in_ped))), :]

		# increase round by 1
		round = round + 1

	end

	#------------------------------------------------------------#
	# Stack Ancestors (with 0's as parents for missing)
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

	# concat ancestors on top of sorted pedigree
	newped = vcat(ped_ancestors, newped)

	#------------------------------------------------------------#
	# Return
	#------------------------------------------------------------#

	# return sorted pedigree
	return newped

end

# export function
export sort_ped





#--------------------------------------------------------------------------------#
# renum_ped() Function
#--------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------#
# Description
#--------------------------------------------------------------------------------#

#   - Input is a pedigree (animal, sire, dam) that can have any IDs (String)
# 	- This function will return a pedigree that is numbered 1 to n
# 	- Int64 DataFrame with 1. animal, 2. sire, 3. dam

#--------------------------------------------------------------------------------#
# Function
#--------------------------------------------------------------------------------#

function renum_ped(ped::DataFrame)

	# subset to only the 1st 3 columns (if there are more)
	ped = ped[:, 1:3]

	# rename columns
	rename!(ped, [:animal, :sire, :dam])

	# add renumbered ID from 1 to n
	ped.RenumID = 1:size(ped, 1)

	# create a dictionary to renumber sires and dams
	dict = Dict{String, Int64}()

	# loop and get a dictionary of old ID with new ID
	for row in eachrow(ped)
		dict[row.animal] = row.RenumID
	end

	# add 0 (String) to dictionary to replace as 0 (Int64)
	dict["0"] = 0

	# add sire renumbred ID
	ped.SireRenumID = map(x -> dict[x], ped.sire)

	# add sire renumbred ID
	ped.DamRenumID = map(x -> dict[x], ped.dam)
	
	# extract renumbered columns
	ped = ped[:, 4:6]

	# return the renumbered pedigree
	return ped

end

# export function
export renum_ped






#--------------------------------------------------------------------------------#
# makeA() function
#--------------------------------------------------------------------------------#

# Austin:  Austin Putz
# Created: 2017-09-27
# Updated: 2023-02-18
# License: MIT
# Version: 0.0.3

#--------------------------------------------------------------------------------#
# Description
#--------------------------------------------------------------------------------#

# Create A with the tabular method

# Make Sure:
#   - Animals are ordered 1,2,...,n
#   - Missing parents are coded as 0

# Example: 
#ped = DataFrame( 
#	animal = [1, 2, 3, 4, 5, 6], 
#	sire   = [0, 0, 1, 1, 4, 5],
#	dam    = [0, 0, 2, 0, 3, 2]
#)

#--------------------------------------------------------------------------------#
# Function
#--------------------------------------------------------------------------------#

# Begin Function
function makeA(ped::DataFrame)

    # check eltypes (should be Int64, not a string)
    if eltype(ped[:,1]) == Int64
        @info "Gave the correct type (Int64)"
    else 
        @info "Gave wrong column type for this algorithm"
        error("Need to provide Int64 numbered 1 to n")
    end

    # pull out animal, sire, dam
    a = ped[:,1]
 	s = ped[:,2]
	d = ped[:,3]

    # add 1 to the sire and dam if ordered 1,2,3,...,n
    sp1 = s .+ 1
    dp1 = d .+ 1

    # I do this because I will add an extra row and column so that
    # when parents are referenced it refers to row 1 or column 1 and
    # I won't need to write a bunch of if/then statements

    # set number of animals
	n = size(ped, 1)

    # add 1 for use in loop (will add a padding of 0's in row 1 and column 1)
	N = n + 1

    # check to make sure the pedigree is ordered 1 to n
    if a[1] != 1
        # throw an error if the first animal isn't listed as animal #1
        error("Pedigree must be sequential 1 to n")
    elseif a[n] != n
        error("Pedigree must be sequential 1 to n")
    end

    # allocate the whole A Matrix
    # This matrix will be padded with a row and column of 0's
	A = zeros(N, N)

    # Begin FOR loop
	for i in 2:N

        # calculate the diagonal element of A
        # diag = 1 + half the relationship of the sire and dam
        A[i, i] = 1 + (A[dp1[i-1], sp1[i-1]] / 2)

        # loop to calculate off-diagonal elements of A
        # Loop down a column for memory efficiency
        for j in (i+1):N
            
            # bottom left triangle of A
            # average the relationship between animal and parents of other individual
            A[j, i] = 0.5 * A[sp1[j-1], i] + 
                      0.5 * A[dp1[j-1], i]
            
            # Symmetric
            A[i, j] = A[j, i]

	    end
    end

	# return the A matrix (remove first row and column)
	return A[2:end, 2:end]

end # end function

# export function
export makeA













