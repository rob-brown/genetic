defmodule Genetic.Problem do
  alias Genetic.Chromosome

  @callback genotype :: Chromosome.t()

  @callback fitness_function(Chromosome.t()) :: number()

  # TODO: Add momentum
  @callback terminate?(Enum.t(), integer()) :: boolean()
end
