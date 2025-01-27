################################################################################
# evolution_tests.jl: unit tests for evolutionary routines of BrkgaMpIpr.
#
# (c) Copyright 2019, Carlos Eduardo de Andrade. All Rights Reserved.
#
# This code is released under LICENSE.md.
#
# Created on:  Apr 19, 2018 by ceandrade
# Last update: Oct 30, 2019 by ceandrade
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
################################################################################

using Printf

include("util.jl")

################################################################################

@testset "evolve_population!()" begin
    start_time = time()

    param_values = deepcopy(default_param_values)
    brkga_params = param_values[param_index["brkga_params"]]
    brkga_params.num_independent_populations = 3
    brkga_params.num_elite_parents = 1
    brkga_params.total_parents = 2
    brkga_data = build_brkga(param_values...)

    # Not initialized
    @test_throws ErrorException BrkgaMpIpr.evolve_population!(brkga_data, 1)

    initialize!(brkga_data)

    @test_throws ArgumentError BrkgaMpIpr.evolve_population!(brkga_data, 0)
    @test_throws ArgumentError BrkgaMpIpr.evolve_population!(brkga_data, -1)
    @test_throws ArgumentError BrkgaMpIpr.evolve_population!(brkga_data,
        brkga_data.params.num_independent_populations + 1)

    # Save previous and current populations locally
    previous = deepcopy(brkga_data.previous)
    current = deepcopy(brkga_data.current)

    ########################
    # Test if algorithm swaps the populations correctly
    ########################

    for i in 1:brkga_data.params.num_independent_populations
        BrkgaMpIpr.evolve_population!(brkga_data, i)

        # Internal current and previous generation must be different.
        @test brkga_data.current[i].chromosomes != brkga_data.previous[i].chromosomes
        @test brkga_data.current[i].fitness != brkga_data.previous[i].fitness

        # The current the from this generation is equal to the previous of
        # the next generation.
        @test current[i].chromosomes == brkga_data.previous[i].chromosomes
        @test current[i].fitness == brkga_data.previous[i].fitness

        # The previous of this generation is lost. Just make sure that
        # the internal swap gets the new generation, not the current one.
        @test previous[i].chromosomes != brkga_data.current[i].chromosomes
        @test previous[i].fitness != brkga_data.current[i].fitness
    end
    println("Elapsed time: $(@sprintf("%.2f", time() - start_time))")

    ########################
    # Test the evolutionary mechanism
    ########################
    # **NOTE:** this test may fail with the random number generation changes.
    # In such case, we have to figure out how to make this test better.

    data_path = joinpath(@__DIR__, "brkga_data_files")

    ########################
    # Data 1
    load_brkga_data(joinpath(data_path, "data1.jld2"), brkga_data)
    results = load(joinpath(data_path, "best_solution1.jld2"))

    BrkgaMpIpr.evolve_population!(brkga_data, 1)
    @test get_best_fitness(brkga_data) ≈ results["fitness1"]
    @test get_best_chromosome(brkga_data) ≈ results["chromosome1"]

    BrkgaMpIpr.evolve_population!(brkga_data, 1)
    @test get_best_fitness(brkga_data) ≈ results["fitness2"]
    @test get_best_chromosome(brkga_data) ≈ results["chromosome2"]

    for _ in 1:100
        BrkgaMpIpr.evolve_population!(brkga_data, 1)
    end
    @test get_best_fitness(brkga_data) ≈ results["fitness102"]
    @test get_best_chromosome(brkga_data) ≈ results["chromosome102"]

    println("Elapsed time: $(@sprintf("%.2f", time() - start_time))")

    ########################
    # Data 2
    load_brkga_data(joinpath(data_path, "data2.jld2"), brkga_data)
    results = load(joinpath(data_path, "best_solution2.jld2"))

    BrkgaMpIpr.evolve_population!(brkga_data, 1)
    @test get_best_fitness(brkga_data) ≈ results["fitness1"]
    @test get_best_chromosome(brkga_data) ≈ results["chromosome1"]

    BrkgaMpIpr.evolve_population!(brkga_data, 2)
    @test get_best_fitness(brkga_data) ≈ results["fitness2"]
    @test get_best_chromosome(brkga_data) ≈ results["chromosome2"]

    for _ in 1:100
        BrkgaMpIpr.evolve_population!(brkga_data, 1)
        BrkgaMpIpr.evolve_population!(brkga_data, 2)
    end
    @test get_best_fitness(brkga_data) ≈ results["fitness102"]
    @test get_best_chromosome(brkga_data) ≈ results["chromosome102"]

    println("Elapsed time: $(@sprintf("%.2f", time() - start_time))")

    ########################
    # Data 3
    load_brkga_data(joinpath(data_path, "data3.jld2"), brkga_data)
    results = load(joinpath(data_path, "best_solution3.jld2"))

    BrkgaMpIpr.evolve_population!(brkga_data, 1)
    @test get_best_fitness(brkga_data) ≈ results["fitness1"]
    @test get_best_chromosome(brkga_data) ≈ results["chromosome1"]

    for _ in 2:brkga_data.params.num_independent_populations
        BrkgaMpIpr.evolve_population!(brkga_data, 2)
    end
    @test get_best_fitness(brkga_data) ≈ results["fitness2"]
    @test get_best_chromosome(brkga_data) ≈ results["chromosome2"]

    for _ in 1:100
        for i in 1:brkga_data.params.num_independent_populations
            BrkgaMpIpr.evolve_population!(brkga_data, i)
        end
    end
    @test get_best_fitness(brkga_data) ≈ results["fitness102"]
    @test get_best_chromosome(brkga_data) ≈ results["chromosome102"]

    println("Elapsed time: $(@sprintf("%.2f", time() - start_time))")

    ########################
    # Data 4 (traditional BRKGA)
    load_brkga_data(joinpath(data_path, "data4.jld2"), brkga_data)
    results = load(joinpath(data_path, "best_solution4.jld2"))

    rho = 0.75
    set_bias_custom_function!(brkga_data, x -> x == 1 ? rho : 1.0 - rho)

    BrkgaMpIpr.evolve_population!(brkga_data, 1)
    @test get_best_fitness(brkga_data) ≈ results["fitness1"]
    @test get_best_chromosome(brkga_data) ≈ results["chromosome1"]

    BrkgaMpIpr.evolve_population!(brkga_data, 2)
    BrkgaMpIpr.evolve_population!(brkga_data, 3)
    @test get_best_fitness(brkga_data) ≈ results["fitness2"]
    @test get_best_chromosome(brkga_data) ≈ results["chromosome2"]

    for _ in 1:100
        for i in 1:brkga_data.params.num_independent_populations
            BrkgaMpIpr.evolve_population!(brkga_data, i)
        end
    end
    @test get_best_fitness(brkga_data) ≈ results["fitness102"]
    @test get_best_chromosome(brkga_data) ≈ results["chromosome102"]

    println("Elapsed time: $(@sprintf("%.2f", time() - start_time))")
end

################################################################################

@testset "evolve!()" begin
    start_time = time()

    param_values = deepcopy(default_param_values)
    brkga_data = build_brkga(param_values...)

    # Not initialized
    @test_throws ErrorException evolve!(brkga_data)

    initialize!(brkga_data)

    @test_throws ArgumentError evolve!(brkga_data, 0)
    @test_throws ArgumentError evolve!(brkga_data, -10)

    #################################
    # Several evolutionary iterations
    #################################

    data_path = joinpath(@__DIR__, "brkga_data_files")
    load_brkga_data(joinpath(data_path, "data5.jld2"), brkga_data)
    results = load(joinpath(data_path, "best_solution5.jld2"))

    evolve!(brkga_data, 1)
    @test get_best_fitness(brkga_data) ≈ results["fitness1"]
    @test get_best_chromosome(brkga_data) ≈ results["chromosome1"]
    println("Elapsed time: $(@sprintf("%.2f", time() - start_time))")

    evolve!(brkga_data, 10)
    @test get_best_fitness(brkga_data) ≈ results["fitness2"]
    @test get_best_chromosome(brkga_data) ≈ results["chromosome2"]
    println("Elapsed time: $(@sprintf("%.2f", time() - start_time))")

    # Evolve step by step, or all generations at once
    # should produce the same results.
    brkga_data2 = deepcopy(brkga_data)
    evolve!(brkga_data, 100)

    for _ in 1:100
        evolve!(brkga_data2, 1)
    end

    @test get_best_fitness(brkga_data) ≈ results["fitness102"]
    @test get_best_chromosome(brkga_data) ≈ results["chromosome102"]
    @test get_best_fitness(brkga_data2) ≈ results["fitness102"]
    @test get_best_chromosome(brkga_data2) ≈ results["chromosome102"]
    println("Elapsed time: $(@sprintf("%.2f", time() - start_time))")
end
