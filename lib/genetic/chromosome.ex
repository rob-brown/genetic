defmodule Genetic.Chromosome do
  @enforce_keys [:genes]
  defstruct [:genes, size: 0, fitness: 0, age: 0]

  @type t :: %__MODULE__{
          genes: Enum.t(),
          size: integer(),
          fitness: any(),
          age: integer()
        }

  def new(genes) do
    %__MODULE__{genes: genes, size: Enum.count(genes)}
  end

  def compare(c1, c2) do
    compare_fitness(c1.fitness, c2.fitness)
  end

  defp compare_fitness(f1 = %{__struct__: module}, f2 = %{__struct__: module}) do
    module.compare(f1, f2)
  end

  defp compare_fitness(f1, f2) do
    case {f1, f2} do
      {first, second} when first > second -> :gt
      {first, second} when first < second -> :lt
      _ -> :eq
    end
  end
end
