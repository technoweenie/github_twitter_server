require 'friendly/attribute'

module Friendly
  # placeholder that represents a boolean
  # since ruby has no boolean superclass
  module Boolean
  end
end

Friendly::Attribute.register_type(Friendly::Boolean, 'boolean') { |s| s }
