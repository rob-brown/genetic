#! /usr/bin/env elixir

Mix.install([
  {:genetic, path: Path.join(__DIR__, "..")}
])

defmodule OneMax do
  alias Genetic.{Problem, BasicChromosome}
  @behaviour Problem

  @impl Problem
  def genotype() do
    genes = for _ <- 1..42, do: Enum.random(0..1)
    BasicChromosome.new(genes)
  end

  @impl Problem
  def update_fitness(c) do
    %BasicChromosome{c | fitness: Enum.sum(c.genes)}
  end

  @impl Problem
  def fitness_module() do
    BasicChromosome
  end

  @impl Problem
  def terminate?(population, _generation) do
    hd(population).fitness == 42
  end
end

options = [
  mutation_type: &Genetic.MutationStrategy.flip/2
]

OneMax |> Genetic.run(options) |> Enum.at(0) |> IO.inspect(label: "Result")
