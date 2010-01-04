module Friendly
  class Memcached
    attr_reader :cache

    def initialize(cache)
      @cache = cache
    end

    def set(key, value)
      @cache.set(key, value)
    end

    def get(key)
      @cache.get(key)
    rescue ::Memcached::NotFound
      if block_given?
        miss(key) { yield }
      end
    end

    def multiget(keys)
      return {} if keys.empty?

      hits         = @cache.get(keys)
      missing_keys = keys - hits.keys

      if !missing_keys.empty? && block_given?
        missing_keys.each do |missing_key|
          hits.merge!(missing_key => miss(missing_key) { yield(missing_key) })
        end
      end

      hits
    end

    def delete(key)
      cache.delete(key)
    rescue ::Memcached::NotFound
    end

    protected
      def miss(key)
        value = yield
        @cache.set(key, value)
        value
      end
  end
end
