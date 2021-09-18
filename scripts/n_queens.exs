#! /usr/bin/env elixir

Mix.install([
  {:genetic, path: Path.join(__DIR__, "..")}
])

defmodule NQueens do
  alias Genetic.{Problem, Chromosome, BasicChromosome}
  @behaviour Problem

  @impl Problem
  def genotype() do
    genes = Enum.shuffle(0..7)
    BasicChromosome.new(genes)
  end

  @impl Problem
  def fitness_module() do
    BasicChromosome
  end

  @impl Problem
  def update_fitness(c) do
    genes = Chromosome.genes(c)

    diag_clashes =
      for i <- 0..7, j <- 0..7 do
        if i != j do
          dx = abs(i - j)

          dy =
            genes
            |> Enum.at(i)
            |> Kernel.-(Enum.at(genes, j))
            |> abs()

          if dx == dy do
            1
          else
            0
          end
        else
          0
        end
      end

    %BasicChromosome{c | fitness: length(Enum.uniq(genes)) - Enum.sum(diag_clashes)}
  end

  @impl Problem
  def terminate?(population, _generation) do
    population |> Enum.at(0) |> then(&(&1.fitness == 8))
    # Enum.max_by(population, &fitness_function/1).fitness == 8
  end
end

NQueens
|> Genetic.run(crossover_type: &Genetic.CrossoverStrategy.order_one/3)
|> Enum.at(0)
|> IO.inspect(label: "Result")
