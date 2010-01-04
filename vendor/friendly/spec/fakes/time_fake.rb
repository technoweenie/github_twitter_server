class TimeFake
  attr_writer :time

  def initialize(time)
    @time = time
  end

  def new
    @time
  end
end

