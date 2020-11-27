defmodule Genetic.CrossoverStrategy do
  alias Genetic.Chromosome

  # TODO: Implement messy single-point, cycle, and multi-point strategies.

  @doc """
  A crossover strategy that keeps the integrity of permutations. Do NOT use on non-permutations.
  """
  def order_one(p1, p2, _opts) do
    limit = p1.size - 1

    # Get random range
    {i1, i2} =
      [:rand.uniform(limit), :rand.uniform(limit)]
      |> Enum.sort()
      |> List.to_tuple()

    # p2 contribution
    slice1 = Enum.slice(p1.genes, i1..i2)
    slice1_set = MapSet.new(slice1)
    p2_contrib = Enum.reject(p2.genes, &MapSet.member?(slice1_set, &1))
    {head1, tail1} = Enum.split(p2_contrib, i1)

    # p1 contribution
    slice2 = Enum.slice(p2.genes, i1..i2)
    slice2_set = MapSet.new(slice2)
    p1_contrib = Enum.reject(p1.genes, &MapSet.member?(slice2_set, &1))
    {head2, tail2} = Enum.split(p1_contrib, i1)

    # Make and return
    c1 = head1 ++ slice1 ++ tail1
    c2 = head2 ++ slice2 ++ tail2
    age = max(p1.age, p2.age) + 1

    {
      %Chromosome{genes: c1, size: p1.size, age: age},
      %Chromosome{genes: c2, size: p2.size, age: age}
    }
  end

  @doc """
  A crossover strategy that chooses a single index in the two chromosome and splits them. Then the tails are swapped between the chromosomes. 
  """
  def single_point(p1, p2, _opts) do
    cx_point = :rand.uniform(p1.size)
    {p1_head, p1_tail} = Enum.split(p1.genes, cx_point)
    {p2_head, p2_tail} = Enum.split(p2.genes, cx_point)
    c1 = p1_head ++ p2_tail
    c2 = p2_head ++ p1_tail
    age = max(p1.age, p2.age) + 1

    {
      %Chromosome{genes: c1, size: p1.size, age: age},
      %Chromosome{genes: c2, size: p2.size, age: age}
    }
  end

  @doc """
  A crossover strategy that trades genes with a given rate. The default rate is 0.5 (50%). This can be changed by setting `:crossover_rate` in `opts`. 
  """
  def uniform(p1, p2, opts) do
    rate = Keyword.get(opts, :crossover_rate, 0.5)
    age = max(p1.age, p2.age) + 1

    {c1, c2} =
      Enum.zip(p1.genes, p2.genes)
      |> Enum.map(fn {x, y} ->
        if :rand.uniform() < rate do
          {x, y}
        else
          {y, x}
        end
      end)
      |> Enum.unzip()

    {
      %Chromosome{genes: c1, size: p1.size, age: age},
      %Chromosome{genes: c2, size: p2.size, age: age}
    }
  end

  @doc """
  A crossover strategy for working with real-value chromosomes. It mathematically mixes the genes of the parents. An alpha of 0.5 (the default) produces two identical children. This can be customized with `:alpha` in the `opts`. 
  """
  def whole_arithmetic(p1, p2, opts) do
    alpha = Keyword.get(opts, :alpha, 0.5)
    age = max(p1.age, p2.age) + 1

    {c1, c2} =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(fn {x, y} -> {x * alpha + y * (1 - alpha), x * (1 - alpha) + y * alpha} end)
      |> Enum.unzip()

    {
      %Chromosome{genes: c1, size: p1.size, age: age},
      %Chromosome{genes: c2, size: p1.size, age: age}
    }
  end
end
