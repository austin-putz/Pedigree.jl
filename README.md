# Pedigree.jl

Pedigree functions implemented in pure Julia. 

Please see the Wiki for more: [Wiki](https://github.com/austin-putz/Pedigree.jl/wiki)

As of now it can:

* Sort a pedigree with any IDs (0 is missing)
* Renumber your pedigree once sorted
* Create the **A** Matrix to use later or extract inbreeding values

See below for examples of each function. 

The key to using my functions is to have the first 3 columns be:

1. Animal
2. Sire
3. Dam

Each will only extract the 1st 3 columns to use, you can have any number
of columns in your pedigree (such as Line or Sex). 

```julia

# load Pkg package
using Pkg

# you can load the Pedigree package with:
# this package is unregistered so you have to load it like this for now
Pkg.add(url="https://github.com/austin-putz/Pedigree.jl")

# load packages
using Pedigree
using DataFrames

# generate pedigree
ped = DataFrame( 
	animal = ["G", "E", "K", "I", "C", "D", "L", "F", "J", "H"], 
	sire   = ["A", "A", "H", "A", "A", "A", "A", "A", "H", "F"], 
	dam    = ["D", "0", "I", "C", "B", "B", "J", "C", "I", "D"]
)

# notice "0" is missing!!

julia> ped
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






<br>
<br>
<br>

## stack_ancestors.jl

We can stack ancestors (parents who are not in the pedigree) on top of the 
pedigree with this function. 

```julia
# load Pedigree package
using Pedigree

# stack ancestors
stack_ancestors(ped)

[ Info: Pedigree is a DataFrame
[ Info: Stacking 2 ancestors on top of the pedigree
12×3 DataFrame
 Row │ animal  sire    dam
     │ String  String  String
─────┼────────────────────────
   1 │ A       0       0
   2 │ B       0       0
   3 │ G       A       D
   4 │ E       A       0
   5 │ K       H       I
   6 │ I       A       C
   7 │ C       A       B
   8 │ D       A       B
   9 │ L       A       J
  10 │ F       A       C
  11 │ J       H       I
  12 │ H       F       D

```



<br>
<br>
<br>

## sort_ped.jl

This function takes a pedigree as a DataFrame (DataFrames.jl) and returns a sorted pedigree with the ancestors stacked on top (if any). 

This will take any DataFrame with 1. Animal, 2. Sire, 3. Dam as a String. 

```julia
using Random

# shuffle order of pedigree (to test sort_ped function)
shuffle!(ped)

# sort the pedigree
sortped = sort_ped(ped)

julia> sortped
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








<br>
<br>
<br>

## renum_ped.jl

This function is to renumber the pedigree from 1 to n and return a 3 column DataFrame as Int64. 

```julia
# renumber the pedigree
renumped = renum_ped(ped)

julia> renumped
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

The `renum_ped()` function will output 6 columns, the first
3 will be the renumbered pedigree, the last 3 will be the 
original IDs. 









<br>
<br>
<br>

## makeA.jl

Create the **A** matrix using the tabular method. 

```julia
# create the A matrix with renumbered pedigree
A = makeA(renumped)

julia> A
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








<br>
<br>
<br>

## Read your own pedigree

You can download this pedigree [here](https://raw.githubusercontent.com/austin-putz/AnS_562_Linear_Models_S2023/main/Data/swine_ped.csv) to test this package. Please then change `working_dir` and `data_file` to your local directory. 

```julia
# load CSV
using CSV

# directory and data file name
working_dir = "/Users/austinputz/Documents/ISU/Classes/AnS_562/2023/Julia/"
data_file   = "pedigree_MSU.csv"

# load swine data
ped_MSU = CSV.read(working_dir * data_file,   # this will just combine the 2 strings
                DataFrame,
                header=true, 
                delim=',', 
                missingstring="NA")

# we can now use this real pedigree to sort, renumber, and calculate A

# sort pedigreee
ped_MSU_sort = sort_ped(ped_MSU)

# renumber pedigree
ped_MSU_renum = renum_ped(ped_MSU_sort)

# calculate A matrix 
A = makeA(ped_MSU_renum)

```






<br>
<br>
<br>

## FAQ (frequently asked questions)

You may have a problem downloading Pedigree.jl with [XSim.jl](), I have alerted Hao Cheng of this situation, but XSim seems to be very behind in it's development to include compatability with new packages. So there is an incompatibility with XSim and key packages like DataFrames. I suggest you remove XSim from your environment until XSim gets updated. 

I do suggest trying to learn XSim, but for now you can also try working with that package in it's own environment. Please search how to separate environments and keep a project for only that package with it's old dependencies. 





