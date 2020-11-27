defmodule Speller do
  alias Genetic.{Problem, Chromosome}
  @behaviour Problem

  @impl Problem
  def genotype() do
    genes = Stream.repeatedly(fn -> Enum.random(?a..?z) end) |> Enum.take(34)
    Chromosome.new(genes)
  end

  @impl Problem
  def fitness_function(chromosome) do
    target = "supercalifragilisticexpialidocious"
    String.jaro_distance(target, List.to_string(chromosome.genes))
  end

  @impl Problem
  def terminate?(population, _generation) do
    hd(population).fitness == 1
  end
end

Speller |> Genetic.run() |> IO.inspect(label: "Result")
