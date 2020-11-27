defmodule CodeBreaker do
  alias Genetic.{Problem, Chromosome}
  @behaviour Problem
  use Bitwise

  @impl Problem
  def genotype() do
    genes = for _ <- 1..64, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: 64}
  end

  @impl Problem
  def fitness_function(chromosome) do
    target = "ILoveGeneticAlgorithms"
    encrypted = 'LIjs`B`k`qlfDibjwlqmhv'
    cipher = fn key -> Enum.map(encrypted, &rem(&1 ^^^ key, 32_768)) end

    key =
      chromosome.genes
      |> Enum.map(&Integer.to_string(&1))
      |> Enum.join("")
      |> String.to_integer(2)

    guess = key |> cipher.() |> List.to_string()
    String.jaro_distance(target, guess)
  end

  @impl Problem
  def terminate?(population, _generation) do
    Enum.max_by(population, &fitness_function/1).fitness == 1
  end
end

solution =
  CodeBreaker
  |> Genetic.run(crossover_type: &Genetic.CrossoverStrategy.single_point/3)
  |> IO.inspect(label: "Result")

solution.genes
|> Enum.map(&Integer.to_string(&1))
|> Enum.join("")
|> String.to_integer(2)
|> IO.inspect(label: "Key")
