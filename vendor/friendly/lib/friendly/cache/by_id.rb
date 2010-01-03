module Friendly
  class Cache
    class ByID < Cache
      def store(document)
        cache.set(cache_key(document.id), document)
      end
      alias_method :create, :store
      alias_method :update, :store

      def destroy(document)
        cache.delete(cache_key(document.id))
      end

      def first(query, &block)
        cache.get(cache_key(query.conditions[:id]), &block)
      end

      def all(query, &block)
        keys = query.conditions[:id].map { |k| cache_key(k) }
        cache.multiget(keys, &block).values
      end

      def satisfies?(query)
        query.conditions.keys == [:id]
      end

      protected
        def cache_key(id)
          [klass.name, version, id.to_guid].join("/")
        end
    end
  end
end
