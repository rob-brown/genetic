defmodule Genetic.Problem do
  alias Genetic.Chromosome

  @callback genotype :: Chromosome.t()

  @callback update_fitness(Chromosome.t()) :: Chromosome.t()

  @callback fitness_module() :: atom()

  # TODO: Add momentum
  @callback terminate?(Enum.t(), integer()) :: boolean()
end
