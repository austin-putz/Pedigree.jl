# Make A Matrix

```@docs
make_A
```

## Description

The `make_A` function creates an additive relationship matrix (A matrix) using the tabular method. This matrix represents the additive genetic relationships between individuals in a pedigree.

## Usage

```julia
using Pedigree
using DataFrames

# Create a sample pedigree (must be numeric and ordered 1 to n)
ped = DataFrame(
    animal = [1, 2, 3, 4, 5, 6], 
    sire   = [0, 0, 1, 1, 4, 5],
    dam    = [0, 0, 2, 0, 3, 2]
)

# Create the A matrix
A = make_A(ped)
```

## Arguments

- `ped::DataFrame`: A DataFrame with 3 columns:
  1. Animal ID (must be integers from 1 to n)
  2. Sire ID (0 for unknown)
  3. Dam ID (0 for unknown)

## Requirements

- The pedigree must be sorted so that parents appear before their offspring
- Animal IDs must be integers from 1 to n
- Missing parents must be coded as 0

## Returns

A square matrix representing the additive genetic relationships between all individuals in the pedigree.