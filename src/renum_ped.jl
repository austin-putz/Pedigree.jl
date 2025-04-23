#--------------------------------------------------------------------------------#
# renum_ped Function
#--------------------------------------------------------------------------------#

"""
    renum_ped(ped::DataFrame)

Renumber a pedigree from 1 to n and convert string IDs to integers.

This function takes a pedigree with string IDs and renumbers all animals from 1 to n,
maintaining the pedigree relationships. It returns a DataFrame with both the new numeric 
IDs and the original string IDs.

# Arguments
- `ped::DataFrame`: A DataFrame with at least 3 columns representing animal ID, sire ID, and dam ID.

# Returns
- `DataFrame`: A new DataFrame with 6 columns:
  1. `RenumID`: Renumbered animal ID (1 to n)
  2. `SireRenumID`: Renumbered sire ID
  3. `DamRenumID`: Renumbered dam ID
  4. `animal`: Original animal ID
  5. `sire`: Original sire ID
  6. `dam`: Original dam ID

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

# Renumber the pedigree
renum_ped = renum_ped(ped)
```
"""
function renum_ped(ped::DataFrame)

	# subset to only the 1st 3 columns
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
	ped = ped[:, [4, 5, 6, 1, 2, 3]]

	# return the renumbered pedigree
	return ped

end
