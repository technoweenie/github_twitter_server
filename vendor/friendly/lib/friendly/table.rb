require 'friendly/storage'
module Friendly
  class Table < Storage
    attr_reader :datastore

    def initialize(datastore)
      @datastore = datastore
    end

    def table_name
      raise NotImplementedError, "#{self.class.name}#table_name is not implemented."
    end
  end
end

