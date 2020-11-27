defmodule Genetic.ReinsertionStrategy do
  @doc """
  A fast reinsertion strategy that could potentially eliminate some strong characteristics from the population.
  """
  def pure(_parents, offspring, _leftovers, _opts) do
    offspring
  end

  @doc """
  A common reinsertion strategy that keeps the top portion of the old population. The percentage kept is set by `:survival_rate` in `opts`. Default is 0.15 (15%).
  """
  def elitist(parents, offspring, leftover, opts) do
    rate = Keyword.get(opts, :survival_rate, 0.15)
    old = parents ++ leftover
    n = trunc(Enum.count(old) * rate)

    survivors =
      old
      |> Enum.sort_by(& &1.fitness, &>=/2)
      |> Enum.take(n)

    offspring ++ survivors
  end

  @doc """
  An uncommon reinsertion strategy that keeps a random selection of the old population. The percentage kept is set by `:survival_rate` in `opts`. Default is 0.15 (15%).
  """
  def uniform(parents, offspring, leftover, opts) do
    rate = Keyword.get(opts, :survival_rate, 0.15)
    old = parents ++ leftover
    n = trunc(Enum.count(old) * rate)
    survivors = Enum.take_random(old, n)

    offspring ++ survivors
  end
end
