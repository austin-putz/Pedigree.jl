#--------------------------------------------------------------------------------#
# check_pedigree Function
#--------------------------------------------------------------------------------#

"""
    check_pedigree(ped::DataFrame)

Check and summarize a pedigree DataFrame.

This function analyzes a pedigree and provides summary statistics including:
- Number of unique animals, sires, and dams
- Duplicate animal IDs (if any)
- Largest full-sib family size
- Statistics on half-sib groups (by sire and dam)
- Count of ancestors not appearing as animals in the pedigree
- Other pedigree structure information

# Arguments
- `ped::DataFrame`: A DataFrame with at least 3 columns representing animal ID, sire ID, and dam ID.

# Returns
- `Dict`: A dictionary containing summary statistics about the pedigree.

# Examples
```julia
using DataFrames
using Pedigree

# Create a sample pedigree
ped = DataFrame(
    animal = ["A", "B", "C", "D", "E"],
    sire = ["0", "0", "B", "B", "B"],
    dam = ["0", "0", "A", "A", "0"]
)

# Check the pedigree
check_pedigree(ped)
```
"""
function check_pedigree(ped::DataFrame)

    # Extract first 3 columns
    ped = ped[:, 1:3]

    # Rename columns: 1. animal, 2. sire, 3. dam
    rename!(ped, [:animal, :sire, :dam])

    # Check if the ped is a DataFrame
    if (typeof(ped) != DataFrame)
        error("Pedigree needs to be a DataFrame")
    end

    # Convert columns to String if needed
    if (eltype(ped.animal) != String)
        @info "Converting animal IDs to String"
        ped.animal = string.(ped.animal)
    end
    if (eltype(ped.sire) != String)
        @info "Converting sire IDs to String"
        ped.sire = string.(ped.sire)
    end
    if (eltype(ped.dam) != String)
        @info "Converting dam IDs to String"
        ped.dam = string.(ped.dam)
    end

    # Initialize results dictionary
    results = Dict{String, Any}()

    # Count total animals
    results["n_rows"] = size(ped, 1)

	# find duplicated IDs, returns DataFrame with only duplicated
	df_duplicate_animals = find_duplicates(ped, :animal)

    # Check for duplicate animal IDs
    # Create a dictionary to count occurrences of each animal ID
    #animal_counts = Dict{String, Int}()
    #for id in ped.animal
    #    animal_counts[id] = get(animal_counts, id, 0) + 1
    #end
    
    #duplicates = filter(p -> p.second > 1, animal_counts)
    results["duplicate_ids"] = df_duplicate_animals.animal
    results["has_duplicates"] = size(df_duplicate_animals)[1] > 0
    
    # Count unique animals
    results["n_animals"] = length(unique(ped.animal))
    
    # Get unique sires and dams (excluding missing values represented as "0")
    unique_sires = filter(x -> x != "0", unique(ped.sire))
    unique_dams = filter(x -> x != "0", unique(ped.dam))
    
	# Count n unique Sires and Dams
    results["n_sires"] = length(unique_sires)
    results["n_dams"] = length(unique_dams)

    # Find ancestors (sires or dams) that don't appear as animals
    all_parents = unique(vcat(ped.sire, ped.dam))
    all_parents = filter(x -> x != "0", all_parents)  # Remove missing values
    
    ancestors_not_in_pedigree = filter(x -> !(x in ped.animal), all_parents)
    results["number_of_external_ancestors"] = length(ancestors_not_in_pedigree)
    results["external_ancestors"] = ancestors_not_in_pedigree

    # Analyze full-sib families (same sire and dam)
    full_sib_groups = Dict{Tuple{String, String}, Int64}()
    
    for row in eachrow(ped)
        if row.sire != "0" && row.dam != "0"  # Only consider animals with both parents known
            key = (row.sire, row.dam)
            full_sib_groups[key] = get(full_sib_groups, key, 0) + 1
        end
    end
    
    if !isempty(full_sib_groups)
        largest_full_sib_family = maximum(values(full_sib_groups))
        results["largest_full_sib_family"] = largest_full_sib_family
        results["number_of_full_sib_families"] = length(full_sib_groups)
    else
        results["largest_full_sib_family"] = 0
        results["number_of_full_sib_families"] = 0
    end

    # Analyze half-sib groups by sire
    sire_half_sib_groups = Dict{String, Vector{String}}()
    
    for row in eachrow(ped)
        if row.sire != "0"  # Only consider animals with known sire
            if !haskey(sire_half_sib_groups, row.sire)
                sire_half_sib_groups[row.sire] = String[]
            end
            push!(sire_half_sib_groups[row.sire], row.animal)
        end
    end
    
    sire_half_sib_sizes = [length(group) for group in values(sire_half_sib_groups)]
    
    if !isempty(sire_half_sib_sizes)
        results["number_of_sire_half_sib_groups"] = length(sire_half_sib_groups)
        results["largest_sire_half_sib_group"] = maximum(sire_half_sib_sizes)
        results["smallest_sire_half_sib_group"] = minimum(sire_half_sib_sizes)
        results["average_sire_half_sib_group_size"] = mean(sire_half_sib_sizes)
    else
        results["number_of_sire_half_sib_groups"] = 0
        results["largest_sire_half_sib_group"] = 0
        results["smallest_sire_half_sib_group"] = 0
        results["average_sire_half_sib_group_size"] = 0
    end

    # Analyze half-sib groups by dam
    dam_half_sib_groups = Dict{String, Vector{String}}()
    
    for row in eachrow(ped)
        if row.dam != "0"  # Only consider animals with known dam
            if !haskey(dam_half_sib_groups, row.dam)
                dam_half_sib_groups[row.dam] = String[]
            end
            push!(dam_half_sib_groups[row.dam], row.animal)
        end
    end
    
    dam_half_sib_sizes = [length(group) for group in values(dam_half_sib_groups)]
    
    if !isempty(dam_half_sib_sizes)
        results["number_of_dam_half_sib_groups"] = length(dam_half_sib_groups)
        results["largest_dam_half_sib_group"] = maximum(dam_half_sib_sizes)
        results["smallest_dam_half_sib_group"] = minimum(dam_half_sib_sizes)
        results["average_dam_half_sib_group_size"] = mean(dam_half_sib_sizes)
    else
        results["number_of_dam_half_sib_groups"] = 0
        results["largest_dam_half_sib_group"] = 0
        results["smallest_dam_half_sib_group"] = 0
        results["average_dam_half_sib_group_size"] = 0
    end

    # Count animals with unknown parents
    results["animals_with_unknown_sire"] = count(x -> x == "0", ped.sire)
    results["animals_with_unknown_dam"] = count(x -> x == "0", ped.dam)
    results["animals_with_both_parents_unknown"] = count(row -> row.sire == "0" && row.dam == "0", eachrow(ped))
    results["animals_with_both_parents_known"] = count(row -> row.sire != "0" && row.dam != "0", eachrow(ped))

    # Print summary
    println("\n=== Pedigree Summary ===")
    println("Total rows in pedigree: $(results["n_rows"])")
    println("Unique animals: $(results["n_animals"])")
    
    if results["has_duplicates"]
        println("\nWARNING: Duplicate animal IDs found:")
        for (id, count) in results["duplicate_ids"]
            println("  $id appears $count times")
        end
    else
        println("No duplicate animal IDs found.")
    end
    
    println("\nNumber of sires: $(results["n_sires"])")
    println("Number of dams: $(results["n_dams"])")
    println("External ancestors (not in animal column): $(results["number_of_external_ancestors"])")
    
    println("\nFamily structure:")
    println("  Full-sib families: $(results["number_of_full_sib_families"])")
    println("  Largest full-sib family size: $(results["largest_full_sib_family"])")
    
    println("\nHalf-sib groups by sire: $(results["number_of_sire_half_sib_groups"])")
    if results["number_of_sire_half_sib_groups"] > 0
        println("  Largest sire half-sib group: $(results["largest_sire_half_sib_group"])")
        println("  Smallest sire half-sib group: $(results["smallest_sire_half_sib_group"])")
        println("  Average sire half-sib group size: $(round(results["average_sire_half_sib_group_size"], digits=2))")
    end
    
    println("\nHalf-sib groups by dam: $(results["number_of_dam_half_sib_groups"])")
    if results["number_of_dam_half_sib_groups"] > 0
        println("  Largest dam half-sib group: $(results["largest_dam_half_sib_group"])")
        println("  Smallest dam half-sib group: $(results["smallest_dam_half_sib_group"])")
        println("  Average dam half-sib group size: $(round(results["average_dam_half_sib_group_size"], digits=2))")
    end
    
    println("\nParent information:")
    println("  Animals with unknown sire: $(results["animals_with_unknown_sire"])")
    println("  Animals with unknown dam: $(results["animals_with_unknown_dam"])")
    println("  Animals with both parents unknown: $(results["animals_with_both_parents_unknown"])")
    println("  Animals with both parents known: $(results["animals_with_both_parents_known"])")

	# add extra space before results (dictionary) printed
	println("\n\n")
    
    return results
end
