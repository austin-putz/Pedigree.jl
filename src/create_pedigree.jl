#--------------------------------------------------------------------------------#
# create_pedigree Function
#--------------------------------------------------------------------------------#

# These imports are handled at the module level in Pedigree.jl
# (Using DataFrames, StatsBase, Random is already done in the module)

"""
    create_pedigree(
        n_base_males::Int, 
        n_base_females::Int, 
        n_males_per_gen::Int, 
        n_females_per_gen::Int, 
        n_offspring_per_mating::Int, 
        n_generations::Int
    )

Generate a pedigree with specified structure and size.

This function creates a simulated pedigree with a specified number of base animals 
and subsequent generations. The pedigree includes animal ID, sire ID, dam ID, 
sex, and generation.

# Arguments
- `n_base_males::Int`: Number of male ancestors with missing parents in the base population
- `n_base_females::Int`: Number of female ancestors with missing parents in the base population
- `n_males_per_gen::Int`: Number of males in each subsequent generation
- `n_females_per_gen::Int`: Number of females in each subsequent generation
- `n_offspring_per_mating::Int`: Number of offspring produced per mating
- `n_generations::Int`: Number of generations to create

# Returns
- `DataFrame`: A DataFrame with columns for animal ID, sire ID, dam ID, sex, and generation

# Examples
```julia
using DataFrames
using Pedigree

# Create a pedigree with 5 base males, 10 base females, 
# 7 males and 15 females per generation,
# 2 offspring per mating, for 3 generations
ped = create_pedigree(5, 10, 7, 15, 2, 3)
```
"""
function create_pedigree(
    n_base_males::Int, 
    n_base_females::Int, 
    n_males_per_gen::Int, 
    n_females_per_gen::Int, 
    n_offspring_per_mating::Int, 
    n_generations::Int
)

    # Validate inputs
    if n_base_males <= 0 || n_base_females <= 0
        error("Number of base males and females must be positive")
    end
    if n_males_per_gen <= 0 || n_females_per_gen <= 0
        error("Number of males and females per generation must be positive")
    end
    if n_offspring_per_mating <= 0
        error("Number of offspring per mating must be positive")
    end
    if n_generations < 0
        error("Number of generations must be non-negative")
    end

    #------------------------------------------------------------#
    # Initialize pedigree
    #------------------------------------------------------------#
    
    # Calculate total number of animals
    n_base = n_base_males + n_base_females
    n_per_gen = n_generations > 0 ? n_generations * (n_males_per_gen + n_females_per_gen) : 0
    total_animals = n_base + n_per_gen
    
    # Initialize empty pedigree
    ped = DataFrame(
        animal = String[],
        sire = String[],
        dam = String[],
        sex = String[],
        generation = Int[]
    )
    
    #------------------------------------------------------------#
    # Create base population (generation 0)
    #------------------------------------------------------------#
    
    # Add base males
    for i in 1:n_base_males
        push!(ped, ["$i", "0", "0", "M", 0])
    end
    
    # Add base females
    for i in (n_base_males+1):(n_base_males+n_base_females)
        push!(ped, ["$i", "0", "0", "F", 0])
    end
    
    # Return if only creating base population
    if n_generations == 0
        return ped
    end
    
    #------------------------------------------------------------#
    # Create subsequent generations
    #------------------------------------------------------------#
    
    # Start ID counter from the end of base population
    id_counter = n_base_males + n_base_females
    
    # For each generation
    for gen in 1:n_generations
        # Find available sires and dams from previous generation
        if gen == 1
            # For first generation, use base population
            available_sires = ped[ped.sex .== "M", :animal]
            available_dams = ped[ped.sex .== "F", :animal]
        else
            # For subsequent generations, use animals from the previous generation
            available_sires = ped[(ped.generation .== gen-1) .& (ped.sex .== "M"), :animal]
            available_dams = ped[(ped.generation .== gen-1) .& (ped.sex .== "F"), :animal]
        end
        
        # Check if we have enough parents
        if length(available_sires) == 0
            error("No male animals available as sires for generation $gen")
        end
        if length(available_dams) == 0
            error("No female animals available as dams for generation $gen")
        end
        
        # Determine number of matings needed
        n_animals_needed = n_males_per_gen + n_females_per_gen
        n_matings = ceil(Int, n_animals_needed / n_offspring_per_mating)
        
        # Sample sires and dams for this generation
        selected_sires = sample(available_sires, n_matings, replace=true)
        selected_dams = sample(available_dams, n_matings, replace=false)
        
        # If we don't have enough unique dams, allow replacement
        if length(available_dams) < n_matings
            selected_dams = sample(available_dams, n_matings, replace=true)
        end
        
        # Create offspring for each mating
        offspring_count = 0
        
        for mating in 1:n_matings
            sire = selected_sires[mating]
            dam = selected_dams[mating]
            
            # Create offspring for this mating
            for _ in 1:n_offspring_per_mating
                offspring_count += 1
                
                # Stop if we've reached the required number of animals for this generation
                if offspring_count > n_animals_needed
                    break
                end
                
                # Increment ID counter
                id_counter += 1
                
                # Determine sex (alternate between male and female to maintain balance)
                sex = offspring_count <= n_males_per_gen ? "M" : "F"
                
                # Add to pedigree
                push!(ped, ["$id_counter", sire, dam, sex, gen])
            end
            
            # Stop creating matings if we've reached the required number of animals
            if offspring_count >= n_animals_needed
                break
            end
        end
    end
    
    return ped
end
