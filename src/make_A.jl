#------------------------------------------------------------------------------#
# makeA4.jl
#------------------------------------------------------------------------------#

# Austin:  Austin Putz
# Created: 2017-09-27
# Updated: 2023-02-18
# License: MIT
# Version: 0.0.3

#------------------------------------------------------------------------------#
# Description
#------------------------------------------------------------------------------#

"""
    make_A(ped::DataFrame)

Create the additive relationship matrix (A matrix) using the tabular method.

This function creates the numerator relationship matrix, which represents the 
additive genetic relationships between all individuals in the pedigree. The method
used is the classic tabular method.

# Arguments
- `ped::DataFrame`: A DataFrame with 3 columns representing animal ID, sire ID, and dam ID.
  The IDs must be integers from 1 to n, with parents appearing before their offspring.
  Missing parents must be coded as 0.

# Returns
- `Matrix{Float64}`: The additive relationship matrix (A), where element A[i,j] is the
  additive genetic relationship between individuals i and j.

# Requirements
- The pedigree must be sorted so that parents appear before their offspring
- Animal IDs must be integers from 1 to n
- Missing parents must be coded as 0

# Examples
```julia
using DataFrames
using Pedigree

# Create a sample pedigree (must be numeric and ordered 1 to n)
ped = DataFrame(
    animal = [1, 2, 3, 4, 5, 6], 
    sire   = [0, 0, 1, 1, 4, 5],
    dam    = [0, 0, 2, 0, 3, 2]
)

# Create the A matrix
A = make_A(ped)
```

# Notes
For large pedigrees, this may be memory intensive. The diagonal elements contain
the inbreeding coefficients plus 1.
"""
function make_A(ped::DataFrame)

    # extract 1st 3 columns (if more from renumered pedigree)
    ped = ped[:, 1:3]

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




