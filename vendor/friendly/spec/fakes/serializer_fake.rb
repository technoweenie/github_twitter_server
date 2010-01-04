class SerializerFake
  attr_writer :generate

  def initialize(opts = {})
    opts.each { |k,v| send("#{k}=", v) }
  end

  def generate(args)
    @generate[args]
  end
end

