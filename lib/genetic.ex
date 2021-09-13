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

  defp evolve(population, problem, generation, opts) do
    population = evaluate(population, &problem.fitness_function/1, opts)
    best = Enum.at(population, 0)
    IO.puts("Current best: #{inspect(best)}")

    if problem.terminate?(population, generation) do
      population
    else
      {parents, leftover} = select(population, opts)
      children = crossover(parents, opts)
      mutants = mutation(population, opts)
      offspring = children ++ mutants
      new_population = reinsertion(parents, offspring, leftover, opts)
      evolve(new_population, problem, generation + 1, opts)
    end
  end

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

  defp evaluate(population, fitness_function, _opts) do
    population
    |> Enum.map(fn c ->
      %Chromosome{c | fitness: fitness_function.(c)}
    end)
    |> Enum.sort({:desc, Chromosome})
  end

  defp select(population, opts) do
    fun = Keyword.get(opts, :selection_type, &SelectionStrategy.natural/3)
    rate = Keyword.get(opts, :selection_rate, 0.8)
    n = trunc(round(Enum.count(population) * rate))
    n = if Integer.is_even(n), do: n, else: n + 1
    parents = fun.(population, n, opts)

    leftover =
      population
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(parents))

    {parents, MapSet.to_list(leftover)}
  end

  defp crossover(parents, opts) do
    fun = Keyword.get(opts, :crossover_type, &CrossoverStrategy.uniform/3)

    parents
    |> Enum.chunk_every(2)
    |> Enum.reduce([], fn [p1, p2], acc ->
      {c1, c2} = fun.(p1, p2, opts)
      [c1, c2 | acc]
    end)
  end

  defp mutation(population, opts) do
    fun = Keyword.get(opts, :mutation_type, &MutationStrategy.scramble/2)
    rate = Keyword.get(opts, :mutation_rate, 0.05)
    n = trunc(Enum.count(population) * rate)

    population
    |> Enum.take_random(n)
    |> Enum.map(&fun.(&1, opts))
  end

  defp reinsertion(parents, offspring, leftover, opts) do
    fun = Keyword.get(opts, :reinsertion_type, &ReinsertionStrategy.elitist/4)
    fun.(parents, offspring, leftover, opts)
  end
end
