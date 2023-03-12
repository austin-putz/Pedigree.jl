# Pedigree.jl

Pedigree functions implemented in Julia

```julia
using DataFrames

# generate pedigree
ped = DataFrame( 
	animal = ["G", "E", "K", "I", "C", "D", "L", "F", "J", "H"], 
	sire   = ["A", "A", "H", "A", "A", "A", "A", "A", "H", "F"], 
	dam    = ["D", "0", "I", "C", "B", "B", "J", "C", "I", "D"]
)

10×3 DataFrame
 Row │ animal  sire    dam
     │ String  String  String
─────┼────────────────────────
   1 │ H       F       D
   2 │ F       A       C
   3 │ K       H       I
   4 │ C       A       B
   5 │ D       A       B
   6 │ G       A       D
   7 │ J       H       I
   8 │ E       A       0
   9 │ I       A       C
  10 │ L       A       J

```

## sort_ped.jl

This function takes a pedigree as a DataFrame (DataFrames.jl) and returns a sorted pedigree with the ancestors stacked on top (if any). 

This will take any DataFrame with 1. Animal, 2. Sire, 3. Dam as a String. 

```julia
using Random

# shuffle order of pedigree (to test sort_ped function)
shuffle!(ped)

# sort the pedigree
sortped = sort_ped(ped)

12×3 DataFrame
 Row │ animal  sire    dam    
     │ String  String  String 
─────┼────────────────────────
   1 │ A       0       0
   2 │ B       0       0
   3 │ C       A       B
   4 │ F       A       C
   5 │ D       A       B
   6 │ H       F       D
   7 │ I       A       C
   8 │ J       H       I
   9 │ K       H       I
  10 │ G       A       D
  11 │ E       A       0
  12 │ L       A       J

```


## renum_ped.jl

This function is to renumber the pedigree from 1 to n and return a 3 column DataFrame as Int64. 

```julia
# renumber the pedigree
renumped = renum_ped(ped)

12×6 DataFrame
 Row │ RenumID  SireRenumID  DamRenumID  animal  sire    dam    
     │ Int64    Int64        Int64       String  String  String 
─────┼──────────────────────────────────────────────────────────
   1 │       1            0           0  A       0       0
   2 │       2            0           0  B       0       0
   3 │       3            1           2  C       A       B
   4 │       4            1           3  F       A       C
   5 │       5            1           2  D       A       B
   6 │       6            4           5  H       F       D
   7 │       7            1           3  I       A       C
   8 │       8            6           7  J       H       I
   9 │       9            6           7  K       H       I
  10 │      10            1           5  G       A       D
  11 │      11            1           0  E       A       0
  12 │      12            1           8  L       A       J

```

## A.jl

Create the A matrix using the tabular method. 

```julia
# create the A matrix with renumbered pedigree
A = makeA(renumped)

12×12 Matrix{Float64}:
 1.0      0.0      0.5      0.75     0.5     0.625    0.75     0.6875   0.6875   0.75      0.5       0.84375
 0.0      1.0      0.5      0.25     0.5     0.375    0.25     0.3125   0.3125   0.25      0.0       0.15625
 0.5      0.5      1.0      0.75     0.5     0.625    0.75     0.6875   0.6875   0.5       0.25      0.59375
 0.75     0.25     0.75     1.25     0.5     0.875    0.75     0.8125   0.8125   0.625     0.375     0.78125
 0.5      0.5      0.5      0.5      1.0     0.75     0.5      0.625    0.625    0.75      0.25      0.5625
 0.625    0.375    0.625    0.875    0.75    1.25     0.625    0.9375   0.9375   0.6875    0.3125    0.78125
 0.75     0.25     0.75     0.75     0.5     0.625    1.25     0.9375   0.9375   0.625     0.375     0.84375
 0.6875   0.3125   0.6875   0.8125   0.625   0.9375   0.9375   1.3125   0.9375   0.65625   0.34375   1.0
 0.6875   0.3125   0.6875   0.8125   0.625   0.9375   0.9375   0.9375   1.3125   0.65625   0.34375   0.8125
 0.75     0.25     0.5      0.625    0.75    0.6875   0.625    0.65625  0.65625  1.25      0.375     0.703125
 0.5      0.0      0.25     0.375    0.25    0.3125   0.375    0.34375  0.34375  0.375     1.0       0.421875
 0.84375  0.15625  0.59375  0.78125  0.5625  0.78125  0.84375  1.0      0.8125   0.703125  0.421875  1.34375

```



