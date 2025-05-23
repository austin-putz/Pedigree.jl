using Documenter, Pedigree

makedocs(
    sitename = "Pedigree.jl",
    modules = [Pedigree],
    format = Documenter.HTML(),
    pages = [
        "Home" => "index.md",
        "Functions" => [
            "stack_ancestors.md",
            "sort_ped.md",
            "renum_ped.md",
            "make_A.md"
        ],
        "API Reference" => "api.md"
    ]
)

deploydocs(
    repo = "github.com/austin-putz/Pedigree.jl.git",
    devbranch = "main",
    push_preview = true,
)