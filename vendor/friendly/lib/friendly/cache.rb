require 'friendly/storage'

module Friendly
  class Cache < Storage
    class << self
      def cache_for(klass, fields, options)
        unless fields == [:id]
          raise NotSupported, "Caching is only possible by id at the moment."
        end

        ByID.new(klass, fields, options)
      end
    end

    attr_reader :klass, :fields, :cache, :version

    def initialize(klass, fields, options = {}, cache = Friendly.cache)
      @klass   = klass
      @fields  = fields
      @cache   = cache
      @version = options[:version] || 0
    end
  end
end
