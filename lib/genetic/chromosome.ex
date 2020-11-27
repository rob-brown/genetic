defmodule Genetic.Chromosome do
  @enforce_keys [:genes]
  defstruct [:genes, size: 0, fitness: 0, age: 0]

  @type t :: %__MODULE__{
          genes: Enum.t(),
          size: integer(),
          fitness: number(),
          age: integer()
        }

  def new(genes) do
    %__MODULE__{genes: genes, size: Enum.count(genes)}
  end
end
