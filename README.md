# Pedigree.jl

Pedigree functions implemented in Julia

```julia
using DataFrames

# generate pedigree
testped = DataFrame( 
	animal = ["G", "E", "K", "I", "C", "D", "L", "F", "J", "H"], 
	sire   = ["A", "A", "H", "A", "A", "A", "A", "A", "H", "F"], 
	dam    = ["D", "0", "I", "C", "B", "B", "J", "C", "I", "D"]
)

```

## sort_ped.jl

This function takes a pedigree as a DataFrame (DataFrames.jl) and returns a sorted pedigree with the ancestors stacked on top (if any). 

This will take any DataFrame with 1. Animal, 2. Sire, 3. Dam as a String. 


## renum_ped.jl

This function is to renumber the pedigree from 1 to n and return a 3 column DataFrame as Int64. 

## A.jl

Create the A matrix using the tabular method. 
