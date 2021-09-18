#! /usr/bin/env elixir

Mix.install([
  {:genetic, path: Path.join(__DIR__, "..")}
])

defmodule Speller do
  alias Genetic.{Problem, BasicChromosome}
  @behaviour Problem

  # @target "supercalifragilisticexpialidocious"
  @target "genetic"

  @impl Problem
  def genotype() do
    genes = Stream.repeatedly(fn -> Enum.random(?a..?z) end) |> Enum.take(String.length(@target))
    BasicChromosome.new(genes)
  end

  @impl Problem
  def fitness_module() do
    BasicChromosome
  end

  @impl Problem
  def update_fitness(chromosome) do
    fitness = String.jaro_distance(@target, List.to_string(chromosome.genes))

    %BasicChromosome{chromosome | fitness: fitness}
  end

  @impl Problem
  def terminate?(population, _generation) do
    hd(population).fitness == 1
  end
end

randomize_letters = fn c, _opts ->
  genes =
    c.genes
    |> Enum.map(fn g ->
      if :rand.uniform() < 0.5 do
        Enum.random(?a..?z)
      else
        g
      end
    end)

  Genetic.Chromosome.spawn(c, genes, c.age + 1)
end

options = [
  population_size: 1000,
  selection_count: 400,
  survival_count: 400,
  mutation_count: 200,
  mutation_type: randomize_letters
]

Speller |> Genetic.run(options) |> Enum.at(0) |> IO.inspect(label: "Result")
