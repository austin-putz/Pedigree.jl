# Renumber Pedigree

```@docs
renum_ped
```

## Description

The `renum_ped` function renumbers a pedigree from 1 to n, creating a new DataFrame with both the original IDs and the renumbered IDs. This is often necessary for computational efficiency in pedigree operations, especially when creating relationship matrices.

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

# Renumber the pedigree
renum_ped = renum_ped(ped)
```

## Arguments

- `ped::DataFrame`: A DataFrame with at least 3 columns:
  1. Animal ID
  2. Sire ID
  3. Dam ID

## Returns

A new DataFrame with the following columns:
1. `RenumID`: Renumbered animal ID (1 to n)
2. `SireRenumID`: Renumbered sire ID
3. `DamRenumID`: Renumbered dam ID
4. `animal`: Original animal ID
5. `sire`: Original sire ID
6. `dam`: Original dam ID