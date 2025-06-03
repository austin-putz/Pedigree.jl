
# load libraries
using Pkg
using Test
using Pedigree
using DataFrames
using Random

# make test pedigree
ped = DataFrames.DataFrame( 
		animal = ["G", "E", "K", "I", "C", "D", "L", "F", "J", "H"], 
		sire   = ["A", "A", "H", "A", "A", "A", "A", "A", "H", "F"], 
		dam    = ["D", "0", "I", "C", "B", "B", "J", "C", "I", "D"]
	)

# shuffle the pedigree
Random.shuffle!(ped)

# stack ancestors
stack_ancestors(ped)

# sort the pedigree
ped_sort = Pedigree.sort_ped(ped)

# renumber the pedigree
ped_renum = Pedigree.renum_ped(ped_sort)

# make A
A = Pedigree.make_A(ped_renum)

# test create_pedigree function
@testset "create_pedigree" begin
    # Create a simple pedigree with 2 base males, 3 base females
    # 2 males and 3 females per generation, 2 offspring per mating, for 2 generations
    test_ped = Pedigree.create_pedigree(2, 3, 2, 3, 2, 2)
    
    # Test basic structure
    @test size(test_ped, 2) == 5  # Should have 5 columns
    @test names(test_ped) == ["animal", "sire", "dam", "sex", "generation"]
    
    # Test base population
    base_animals = test_ped[test_ped.generation .== 0, :]
    @test size(base_animals, 1) == 5  # 2 males + 3 females
    @test count(base_animals.sex .== "M") == 2  # 2 males
    @test count(base_animals.sex .== "F") == 3  # 3 females
    @test all(base_animals.sire .== "0")  # All sires should be "0"
    @test all(base_animals.dam .== "0")   # All dams should be "0"
    
    # Test generation 1
    gen1_animals = test_ped[test_ped.generation .== 1, :]
    @test size(gen1_animals, 1) == 5  # 2 males + 3 females
    @test count(gen1_animals.sex .== "M") == 2  # 2 males
    @test count(gen1_animals.sex .== "F") == 3  # 3 females
    @test all(gen1_animals.sire .!= "0")  # No sires should be "0"
    @test all(gen1_animals.dam .!= "0")   # No dams should be "0"
    
    # Test generation 2
    gen2_animals = test_ped[test_ped.generation .== 2, :]
    @test size(gen2_animals, 1) == 5  # 2 males + 3 females
    @test count(gen2_animals.sex .== "M") == 2  # 2 males
    @test count(gen2_animals.sex .== "F") == 3  # 3 females
    
    # Test total size
    @test size(test_ped, 1) == 15  # 5 base + 5 gen1 + 5 gen2
    
    # Test pedigree integrity
    @test check_pedigree(test_ped)["has_duplicates"] == false
end




