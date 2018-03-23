#!/usr/bin/env julia
################################################################################
# runtests.jl: unit tests for BrkgaMpIpr
#
# (c) Copyright 2018, Carlos Eduardo de Andrade. All Rights Reserved.
#
# This code is released under LICENSE.md.
#
# Created on:  Mar 20, 2018 by ceandrade
# Last update: Mar 23, 2018 by ceandrade
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

using BrkgaMpIpr
using Base.Test

include("TestInstance.jl")
include("TestDecoder.jl")

using TestInstance
using TestDecoder

################################################################################
# General objects for testing
################################################################################

instance = Instance(10)

# Makes easy to change espeficif position on the parameters vector below.
const param_names = ["instance", "decode!", "opt_sense", "seed", "chr_size",
                     "pop_size", "elite_percentage", "mutants_percentage",
                     "evolutionary_mechanism_on", "num_elite_parents",
                     "total_parents", "bias", "num_independent_populations"]

# Reverse index.
const param_index = Dict([v => i for (i, v) in enumerate(param_names)])

# Holds the parameters to build new BrkgaData.
param_values = Array{Any, 1}(length(param_names))

# Some default parameters.
param_values[param_index["instance"]] = instance
param_values[param_index["decode!"]] = decode!
param_values[param_index["opt_sense"]] = BrkgaMpIpr.MAXIMIZE
param_values[param_index["seed"]] = 2700001
param_values[param_index["chr_size"]] = 100
param_values[param_index["pop_size"]] = 10
param_values[param_index["elite_percentage"]] = 0.3
param_values[param_index["mutants_percentage"]] = 0.1
param_values[param_index["evolutionary_mechanism_on"]] = true
param_values[param_index["num_elite_parents"]] = 1
param_values[param_index["total_parents"]] = 2
param_values[param_index["bias"]] = BrkgaMpIpr.LOGINVERSE
param_values[param_index["num_independent_populations"]] = 1

# Used to restore original param_values.
const clean_slate = copy(param_values)

################################################################################

@testset "Detailed build_brkga" begin
    # Test regular/correct building.
    brkga_data = BrkgaMpIpr.build_brkga(param_values...)
    @test brkga_data.elite_size == 3
    @test brkga_data.num_mutants == 1
    @test length(brkga_data.previous) == param_values[param_index["num_independent_populations"]]
    @test length(brkga_data.current) == param_values[param_index["num_independent_populations"]]
    @test length(brkga_data.shuffled_individuals) == param_values[param_index["pop_size"]]
    @test length(brkga_data.parents_ordered) == param_values[param_index["pop_size"]]

    local_rng = MersenneTwister(param_values[param_index["seed"]])
    rand(local_rng, 1000)
    @test rand(brkga_data.rng) == rand(local_rng)

    # Test multi-start building.
    param_values[param_index["evolutionary_mechanism_on"]] = false
    param_values[param_index["pop_size"]] = 10
    brkga_data = BrkgaMpIpr.build_brkga(param_values...)
    @test brkga_data.elite_size == 1
    @test brkga_data.num_mutants == 9

    param_values = copy(clean_slate)

    # Test bias functions.

    param_values[param_index["bias"]] = BrkgaMpIpr.LOGINVERSE
    brkga_data = BrkgaMpIpr.build_brkga(param_values...)
    @test brkga_data.bias_function(1) ≈ 1.4426950408889634
    @test brkga_data.bias_function(2) ≈ 0.9102392266268375
    @test brkga_data.bias_function(3) ≈ 0.7213475204444817

    param_values[param_index["bias"]] = BrkgaMpIpr.LINEAR
    brkga_data = BrkgaMpIpr.build_brkga(param_values...)
    @test brkga_data.bias_function(1) ≈ 1.0
    @test brkga_data.bias_function(2) ≈ 0.5
    @test brkga_data.bias_function(3) ≈ 0.3333333333333333

    param_values[param_index["bias"]] = BrkgaMpIpr.QUADRATIC
    brkga_data = BrkgaMpIpr.build_brkga(param_values...)
    @test brkga_data.bias_function(1) ≈ 1.0
    @test brkga_data.bias_function(2) ≈ 0.25
    @test brkga_data.bias_function(3) ≈ 0.1111111111111111

    param_values[param_index["bias"]] = BrkgaMpIpr.CUBIC
    brkga_data = BrkgaMpIpr.build_brkga(param_values...)
    @test brkga_data.bias_function(1) ≈ 1.0
    @test brkga_data.bias_function(2) ≈ 0.125
    @test brkga_data.bias_function(3) ≈ 0.037037037037037035

    param_values[param_index["bias"]] = BrkgaMpIpr.EXPONENTIAL
    brkga_data = BrkgaMpIpr.build_brkga(param_values...)
    @test brkga_data.bias_function(1) ≈ 0.36787944117144233
    @test brkga_data.bias_function(2) ≈ 0.1353352832366127
    @test brkga_data.bias_function(3) ≈ 0.049787068367863944

    param_values[param_index["bias"]] = BrkgaMpIpr.CONSTANT
    brkga_data = BrkgaMpIpr.build_brkga(param_values...)
    @test brkga_data.bias_function(1) ≈ 0.5
    @test brkga_data.bias_function(2) ≈ 0.5
    @test brkga_data.bias_function(3) ≈ 0.5

    param_values = copy(clean_slate)

    ########################
    # Test exceptions.
    ########################

    # Chromosome size
    param_values[param_index["chr_size"]] = 0
    @test_throws ArgumentError BrkgaMpIpr.build_brkga(param_values...)

    param_values[param_index["chr_size"]] = -10
    @test_throws ArgumentError BrkgaMpIpr.build_brkga(param_values...)

    param_values = copy(clean_slate)

    # Population size
    param_values[param_index["pop_size"]] = 0
    @test_throws ArgumentError BrkgaMpIpr.build_brkga(param_values...)

    param_values[param_index["pop_size"]] = -10
    @test_throws ArgumentError BrkgaMpIpr.build_brkga(param_values...)

    param_values = copy(clean_slate)

    # Elite size.
    param_values[param_index["elite_percentage"]] = 0.0
    @test_throws ArgumentError BrkgaMpIpr.build_brkga(param_values...)

    param_values[param_index["elite_percentage"]] = -10.0
    @test_throws ArgumentError BrkgaMpIpr.build_brkga(param_values...)

    param_values[param_index["elite_percentage"]] = 0.3
    param_values[param_index["pop_size"]] = 2
    @test_throws ArgumentError BrkgaMpIpr.build_brkga(param_values...)

    param_values[param_index["elite_percentage"]] = 1.1
    param_values[param_index["pop_size"]] = 10
    @test_throws ArgumentError BrkgaMpIpr.build_brkga(param_values...)

    param_values = copy(clean_slate)

    # Mutant size.
    param_values[param_index["mutants_percentage"]] = -10.0
    @test_throws ArgumentError BrkgaMpIpr.build_brkga(param_values...)

    param_values[param_index["mutants_percentage"]] = 1.0
    @test_throws ArgumentError BrkgaMpIpr.build_brkga(param_values...)

    param_values[param_index["mutants_percentage"]] = 1.1
    @test_throws ArgumentError BrkgaMpIpr.build_brkga(param_values...)

    param_values = copy(clean_slate)

    # Elite + Mutant size.
    param_values[param_index["elite_percentage"]] = 0.6
    param_values[param_index["mutants_percentage"]] = 0.6
    @test_throws ArgumentError BrkgaMpIpr.build_brkga(param_values...)

    param_values = copy(clean_slate)

    # Elite parents for mating.
    param_values[param_index["num_elite_parents"]] = 0
    @test_throws ArgumentError BrkgaMpIpr.build_brkga(param_values...)

    param_values[param_index["num_elite_parents"]] = 2
    param_values[param_index["total_parents"]] = 2
    @test_throws ArgumentError BrkgaMpIpr.build_brkga(param_values...)

    param_values[param_index["num_elite_parents"]] = 1 +
               ceil(Int64, param_values[param_index["pop_size"]] *
                           param_values[param_index["elite_percentage"]])
    param_values[param_index["total_parents"]] = 1 +
               param_values[param_index["num_elite_parents"]]
    @test_throws ArgumentError BrkgaMpIpr.build_brkga(param_values...)

    param_values = copy(clean_slate)

    # Number of independent populations.
    param_values[param_index["num_independent_populations"]] = 0
    @test_throws ArgumentError BrkgaMpIpr.build_brkga(param_values...)

    param_values = copy(clean_slate)

    # TODO (ceandrade): check path relink params here
end

################################################################################

@testset "set_bias_custom_function" begin
    param_values = copy(clean_slate)
    param_values[param_index["total_parents"]] = 10
    brkga_data = BrkgaMpIpr.build_brkga(param_values...)

    @test_throws ArgumentError set_bias_custom_function!(brkga_data, x -> x)
    @test_throws ArgumentError set_bias_custom_function!(brkga_data, x -> x + 1)
    @test_throws ArgumentError set_bias_custom_function!(brkga_data, x -> log1p(x))

    set_bias_custom_function!(brkga_data, x -> 1.0 / log1p(x))
    @test brkga_data.total_bias_weight ≈ 6.554970525044798

    set_bias_custom_function!(brkga_data, x -> 1.0 / x)
    @test brkga_data.total_bias_weight ≈ 2.9289682539682538

    set_bias_custom_function!(brkga_data, x -> x ^ -2.0)
    @test brkga_data.total_bias_weight ≈ 1.5497677311665408

    set_bias_custom_function!(brkga_data, x -> x ^ -3.0)
    @test brkga_data.total_bias_weight ≈ 1.197531985674193

    set_bias_custom_function!(brkga_data, x -> exp(-x))
    @test brkga_data.total_bias_weight ≈ 0.5819502851677112

    set_bias_custom_function!(brkga_data, x -> 1.0 / brkga_data.total_parents)
    @test brkga_data.total_bias_weight ≈ 0.9999999999999999

    set_bias_custom_function!(brkga_data, x -> 0.6325 / sqrt(x))
    @test brkga_data.total_bias_weight ≈ 3.175781171302612
end
