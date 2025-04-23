# Sort Pedigree

```@docs
sort_ped
```

## Description

The `sort_ped` function sorts a pedigree in ancestral order, ensuring that parents appear before their offspring. This is important for many pedigree operations, particularly for constructing relationship matrices.

## Usage

```julia
using Pedigree
using DataFrames

# Create a sample pedigree
ped = DataFrame(
    animal = ["A", "B", "C", "D"],
    sire = ["0", "0", "B", "B"],
    dam = ["0", "0", "A", "C"]
)

# Sort the pedigree
sorted_ped = sort_ped(ped)
```

## Arguments

- `ped::DataFrame`: A DataFrame with at least 3 columns:
  1. Animal ID
  2. Sire ID
  3. Dam ID
- `maxrounds::Int`: (Optional) Maximum number of iterations to attempt sorting (default: 1000)

## Returns

A new DataFrame containing the sorted pedigree with ancestors at the top and descendants below.