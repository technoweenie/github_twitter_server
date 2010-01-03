class DataStoreFake
  attr_writer :insert, :all, :first
  attr_reader :inserts, :updates

  def initialize(opts = {})
    opts.each { |k,v| send("#{k}=", v) }
    @inserts = []
    @updates = []
  end

  def insert(*args)
    @inserts << args
    @insert
  end

  def update(*args)
    @updates << args
    @update
  end

  def all(*args)
    @all[args]
  end

  def first(*args)
    @first[args]
  end
end

