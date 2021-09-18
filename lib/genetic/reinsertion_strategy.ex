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
  def elitist(parents, offspring, leftover, fitness_module, opts) do
    count = Keyword.get(opts, :survival_count, nil)
    old = parents ++ leftover

    n =
      if count do
        count
      else
        rate = Keyword.get(opts, :survival_rate, 0.15)
        trunc(Enum.count(old) * rate)
      end

    survivors =
      old
      |> Enum.sort({:desc, fitness_module})
      |> Enum.take(n)

    offspring ++ survivors
  end

  @doc """
  An uncommon reinsertion strategy that keeps a random selection of the old population. The percentage kept is set by `:survival_rate` in `opts`. Default is 0.15 (15%).
  """
  def uniform(parents, offspring, leftover, _fitness_module, opts) do
    count = Keyword.get(opts, :survival_count, nil)
    old = parents ++ leftover

    n =
      if count do
        count
      else
        rate = Keyword.get(opts, :survival_rate, 0.15)
        trunc(Enum.count(old) * rate)
      end

    survivors = Enum.take_random(old, n)

    offspring ++ survivors
  end
end
