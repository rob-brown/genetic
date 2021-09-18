defprotocol Genetic.Chromosome do
  def genes(t)

  def gene_count(t)

  def age(t)

  def compare(t1, t2)

  def spawn(t, genes, age)
end
