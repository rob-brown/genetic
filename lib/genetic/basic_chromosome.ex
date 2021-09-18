defmodule Genetic.BasicChromosome do
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

defimpl Genetic.Chromosome, for: Genetic.BasicChromosome do
  def genes(%@for{genes: genes}) do
    genes
  end

  def gene_count(%@for{size: size}) do
    size
  end

  def age(%@for{age: age}) do
    age
  end

  def compare(t1, t2) do
    @for.compare(t1, t2)
  end

  def spawn(_t, genes, age) do
    %@for{genes: genes, size: Enum.count(genes), age: age, fitness: 0}
  end
end
