
# load libraries
import Pkg
#import Pedigree
include("../functions.jl")
using Pedigree
using Test
using DataFrames
using Random

# test Pedigree package
@testset "Pedigree.jl" begin

	@test ped = DataFrames.DataFrame( 
		animal = ["G", "E", "K", "I", "C", "D", "L", "F", "J", "H"], 
		sire   = ["A", "A", "H", "A", "A", "A", "A", "A", "H", "F"], 
		dam    = ["D", "0", "I", "C", "B", "B", "J", "C", "I", "D"]
	)

	@test Random.shuffle!(ped)

    @test ped_sort = Pedigree.sort_ped(ped)

    @test ped_renum = Pedigree.renum_ped(ped_sort)

    @test A = Pedigree.makeA(ped_renum)

	@test println(A)

end













