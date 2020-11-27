defmodule OneMax do
  alias Genetic.{Problem, Chromosome}
  @behaviour Problem

  @impl Problem
  def genotype() do
    genes = for _ <- 1..42, do: Enum.random(0..1)
    Chromosome.new(genes)
  end

  @impl Problem
  def fitness_function(chromosome) do
    Enum.sum(chromosome.genes)
  end

  @impl Problem
  def terminate?(population, _generation) do
    hd(population).fitness == 42
  end
end

OneMax |> Genetic.run() |> IO.inspect(label: "Result")
