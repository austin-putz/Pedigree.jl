# Stack Ancestors

```@docs
stack_ancestors
```

## Description

The `stack_ancestors` function identifies and adds missing ancestors to a pedigree. Animals that appear as parents but are not in the pedigree as individuals are added as new rows with unknown parentage.

## Usage

```julia
using Pedigree
using DataFrames

# Create a sample pedigree
ped = DataFrame(
    animal = ["A", "B", "C"],
    sire = ["X", "0", "B"],
    dam = ["Y", "0", "A"]
)

# Stack missing ancestors
stacked_ped = stack_ancestors(ped)
```

In this example, "X" and "Y" would be added to the pedigree with "0" (unknown) parents.

## Arguments

- `ped::DataFrame`: A DataFrame with at least 3 columns:
  1. Animal ID
  2. Sire ID
  3. Dam ID

## Returns

A new DataFrame with ancestors added at the top, where each row represents an animal with its sire and dam.