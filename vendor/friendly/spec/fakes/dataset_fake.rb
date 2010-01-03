class DatasetFake
  attr_accessor :where, :insert, :inserts, :update, :updates, :first

  def initialize(opts = {})
    opts.each { |k,v| send("#{k}=", v) }
    @inserts ||= []
    @updates ||= []
  end

  def where(conditions)
    @where.detect { |k,v| k == conditions }.last
  end

  def insert(attributes)
    inserts << attributes
    @insert
  end

  def update(attributes)
    updates << attributes
    @update
  end

  def first(conditions)
    @first.detect { |k,v| k == conditions }.last
  end
end

