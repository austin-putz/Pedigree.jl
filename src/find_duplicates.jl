#--------------------------------------------------------------------------------#
# find_duplicates Function
#--------------------------------------------------------------------------------#

"""
    find_duplicates(df::DataFrame, id_column::Symbol)

Find duplicated IDs in a DataFrame.

This function identifies and counts duplicate entries in a specified column.

# Arguments
- `df::DataFrame`: A DataFrame to check for duplicates
- `id_column::Symbol`: The column to check for duplicates

# Returns
- `duplicates::DataFrame`: A DataFrame with duplicated IDs and their counts

# Examples
```julia
using DataFrames
using Pedigree

# Create a sample pedigree
ped = DataFrame(
    animal = ["A", "A", "B", "C", "D", "E"],
    sire = ["0", "0", "0", "B", "B", "B"],
    dam  = ["0", "0", "0", "A", "A", "0"]
)

# Check the pedigree
find_duplicates(ped, :animal)
```
"""
function find_duplicates(df, id_column)
    # Group by ID and count occurrences
    duplicate_counts = combine(groupby(df, id_column), nrow => :count)

    # Filter to keep only duplicated IDs (count > 1)
    duplicates = filter(row -> row.count > 1, duplicate_counts)

    # Sort by count (descending)
    sort!(duplicates, :count, rev=true)

    return duplicates
end

