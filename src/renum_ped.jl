#--------------------------------------------------------------------------------#
# renum_ped Function
#--------------------------------------------------------------------------------#

# Description:
# 	- This function will return a pedigree that is numbered 1 to n
# 	- Will return as an Int64 DataFrame

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
	ped = ped[:, 4:6]

	# return the renumbered pedigree
	return ped

end
