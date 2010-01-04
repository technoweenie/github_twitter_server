class DatabaseFake
  attr_accessor :from

  def initialize(from)
    @from = from
  end

  def from(table)
    @from[table]
  end
end

