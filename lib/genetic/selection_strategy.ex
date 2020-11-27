defmodule Genetic.SelectionStrategy do
  # TODO: Implement Boltzmann, stochastic universal sampling, and rank strategies.

  @doc """
  A simple selection strategy that takes the `n` best chromosomes by fitness. Can lead to premature convergence.
  """
  def natural(population, n, _opts) do
    Enum.take(population, n)
  end

  @doc """
  A simple selection strategy that takes `n` random chromosomes. Uncommonly used but preserves diversity.
  """
  def random(population, n, _opts) do
    Enum.take_random(population, n)
  end

  @doc """
  A selection strategy that picks chromosomes at random with a weight proportional to their fitness. Slow but does well with maintaining fitness and diversity. Try other strategries before resorting to this one.
  """
  def roulette(population, n, _opts) do
    sum_fitness = population |> Enum.map(& &1.fitness) |> Enum.sum()

    for _ <- 1..n do
      u = :rand.uniform() * sum_fitness

      Enum.reduce_while(population, 0, fn x, sum ->
        if x.fitness + sum > u do
          {:halt, x}
        else
          {:cont, x.fitness + sum}
        end
      end)
    end
  end

  @doc """
  A selection strategy that balances diversity and fitness. The tournament size can be specified with `:tournament_size` in `opts`. This defaults to `n`. A size of 1 is the same as `random/3`. A size of `n` is the same as `natural/3`. 
  """
  def tournament(population, n, opts) do
    tournament_size = Keyword.get(opts, :tournament_size, n)

    for _ <- 1..n do
      population
      |> Enum.take_random(tournament_size)
      |> Enum.max_by(& &1.fitness)
    end
  end

  @doc """
  A selection strategy similar to `tournament/3` except it doesn't allow for duplicates. 
  """
  def tournament_no_duplicates(population, n, opts) do
    tournament_size = Keyword.get(opts, :tournament_size, n)
    tournament_helper(MapSet.new(), population, n, tournament_size)
  end

  defp tournament_helper(selected, population, n, tournament_size) do
    if MapSet.size(selected) == n do
      MapSet.to_list(selected)
    else
      population
      |> Enum.take_random(tournament_size)
      |> Enum.max_by(& &1.fitness)
      |> (&MapSet.put(selected, &1)).()
      |> tournament_helper(population, n, tournament_size)
    end
  end
end
