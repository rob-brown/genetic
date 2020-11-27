defmodule Genetic.MutationStrategy do
  alias Genetic.Chromosome
  use Bitwise

  # TODO: Implement swap, uniform, and invert strategies.

  @doc """
  A mutation strategy for binary genotypes. Do NOT use on other genotypes. Flips 0 to 1 and vice versa. Setting `:flip_rate` in `opts` changes the probability of flipping a bit. Default is 0.5 (50%).
  """
  def flip(c = %Chromosome{}, opts) do
    rate = Keyword.get(opts, :flip_rate, 0.5)

    genes =
      Enum.map(c.genes, fn g ->
        if :rand.uniform() < rate do
          g ^^^ 1
        else
          g
        end
      end)

    %Chromosome{c | genes: genes, age: c.age + 1}
  end

  @doc """
  Shuffles all the genes in the chromosome. Works with binary, permutation, and some real-value genotypes.
  """
  def scramble(c = %Chromosome{}, _opts) do
    %Chromosome{c | genes: Enum.shuffle(c.genes), age: c.age + 1}
  end

  @doc """
  Shuffles a random slice of the genes in the chromosome. Works with binary, permutation, and some real-value genotypes. The slice size can be set with `:scramble_size` in `opts`. Defaults to the size of the chromosome. This makes it the same as `scramble/2`.
  """
  def scramble_slice(c = %Chromosome{}, opts) do
    n = Keyword.get(opts, :scramble_size, c.size)

    if n >= c.size do
      scramble(c, opts)
    else
      lo = :rand.uniform(c.size - n)
      hi = lo + n
      head = Enum.slice(c.genes, 0, lo)
      mid = Enum.slice(c.genes, lo, n)
      tail = Enum.slice(c.genes, hi, c.size)
      genes = head ++ Enum.shuffle(mid) ++ tail

      %Chromosome{c | genes: genes, age: c.age + 1}
    end
  end

  @doc """
  A mutation strategy that modifies all the genes according to the normal distribution of the current genes. Slightly adjusts the chromosome without changing it too much. One of the most effective mutations for real-world genotypes. Balances diversity and fitness over time.
  """
  def gaussian(c = %Chromosome{}, _opts) do
    mu = Enum.sum(c.genes) / c.size

    sigma =
      c.genes
      |> Enum.map(fn x -> (mu - x) * (mu - x) end)
      |> Enum.sum()
      |> Kernel./(c.size)

    genes = Enum.map(c.genes, fn _ -> :rand.normal(mu, sigma) end)

    %Chromosome{c | genes: genes, age: c.age + 1}
  end
end
