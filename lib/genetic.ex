defmodule Genetic do
  require Integer

  alias Genetic.{
    Chromosome,
    SelectionStrategy,
    CrossoverStrategy,
    MutationStrategy,
    ReinsertionStrategy
  }

  @spec run(Genetic.Problem.t(), Keyword.t()) :: [Chromosome.t()]
  def run(problem, opts \\ []) do
    problem
    |> initialize(opts)
    |> evolve(problem, 0, opts)
  end

  ## Helpers

  # Recursively creates new populations through selection, crossover, mutation, and reinsertion.
  defp evolve(population, problem, generation, opts) do
    population = evaluate(population, problem, opts)
    best = Enum.at(population, 0)
    IO.puts("Current best: #{inspect(best)}")

    if problem.terminate?(population, generation) do
      population
    else
      {parents, leftover} = select(population, opts)
      children = crossover(parents, opts)
      mutants = mutation(population, opts)
      offspring = children ++ mutants
      new_population = reinsertion(parents, offspring, leftover, problem.fitness_module(), opts)
      evolve(new_population, problem, generation + 1, opts)
    end
  end

  # Sets up the initial population.
  defp initialize(problem, opts) do
    case Keyword.fetch(opts, :initial_population) do
      {:ok, genotypes} ->
        genotypes

      :error ->
        n = Keyword.get(opts, :population_size, 100)

        for _ <- 1..n do
          problem.genotype()
        end
    end
  end

  # Sorts the population by fitness.
  defp evaluate(population, problem, _opts) do
    population
    |> Enum.map(&problem.update_fitness/1)
    |> Enum.sort({:desc, problem.fitness_module()})
  end

  # Splits the population into parents and leftovers.
  defp select(population, opts) do
    fun = Keyword.get(opts, :selection_type, &SelectionStrategy.natural/3)
    count = Keyword.get(opts, :selection_count, nil)

    n =
      if count do
        count
      else
        rate = Keyword.get(opts, :selection_rate, 0.8)
        n = trunc(round(Enum.count(population) * rate))
        if Integer.is_even(n), do: n, else: n + 1
      end

    parents = fun.(population, n, opts)

    leftover =
      population
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(parents))

    {parents, MapSet.to_list(leftover)}
  end

  # The parents produce offspring.
  defp crossover(parents, opts) do
    fun = Keyword.get(opts, :crossover_type, &CrossoverStrategy.uniform/3)

    parents
    |> Enum.chunk_every(2)
    |> Enum.reduce([], fn [p1, p2], acc ->
      {c1, c2} = fun.(p1, p2, opts)
      [c1, c2 | acc]
    end)
  end

  # Random members of the population are mutated.
  defp mutation(population, opts) do
    fun = Keyword.get(opts, :mutation_type, &MutationStrategy.scramble/2)
    count = Keyword.get(opts, :mutation_count, nil)

    n =
      if count do
        count
      else
        rate = Keyword.get(opts, :mutation_rate, 0.05)
        trunc(Enum.count(population) * rate)
      end

    population
    |> Enum.take_random(n)
    |> Enum.map(&fun.(&1, opts))
  end

  # Creates a new population.
  defp reinsertion(parents, offspring, leftover, fitness_module, opts) do
    fun = Keyword.get(opts, :reinsertion_type, &ReinsertionStrategy.elitist/5)
    fun.(parents, offspring, leftover, fitness_module, opts)
  end
end
