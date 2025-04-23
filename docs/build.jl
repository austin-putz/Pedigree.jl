#!/usr/bin/env julia

# Documentation build script

using Pkg

# Activate docs environment
Pkg.activate(@__DIR__)

# Add dependencies if not already present
deps = [
    "Documenter",
    "Pedigree"
]

for dep in deps
    try
        Pkg.add(dep)
    catch
        @warn "Could not add $dep"
    end
end

# Include the make.jl file to build the documentation
include("make.jl")