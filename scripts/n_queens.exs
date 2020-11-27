defmodule NQueens do
  alias Genetic.{Problem, Chromosome}
  @behaviour Problem

  @impl Problem
  def genotype() do
    genes = Enum.shuffle(0..7)
    Chromosome.new(genes)
  end

  @impl Problem
  def fitness_function(chromosome) do
    diag_clashes =
      for i <- 0..7, j <- 0..7 do
        if i != j do
          dx = abs(i - j)

          dy =
            chromosome.genes
            |> Enum.at(i)
            |> Kernel.-(Enum.at(chromosome.genes, j))
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

    length(Enum.uniq(chromosome.genes)) - Enum.sum(diag_clashes)
  end

  @impl Problem
  def terminate?(population, _generation) do
    Enum.max_by(population, &fitness_function/1).fitness == 8
  end
end

NQueens
|> Genetic.run(crossover_type: &Genetic.CrossoverStrategy.order_one/3)
|> IO.inspect(label: "Result")
