require 'friendly/storage_factory'
require 'friendly/table_creator'

module Friendly
  class StorageProxy
    attr_reader :klass, :storage_factory, :tables, :table_creator, :caches

    def initialize(klass, storage_factory = StorageFactory.new,
                    table_creator=TableCreator.new)
      super()
      @klass           = klass
      @storage_factory = storage_factory
      @table_creator   = table_creator
      @tables          = [storage_factory.document_table(klass)]
      @caches          = []
    end

    def first(conditions)
      first_from_cache(conditions) do
        index_for(conditions).first(conditions)
      end
    end

    def all(query)
      objects = perform_all(query).compact
      if query.preserve_order?
        order = query.conditions[:id]
        objects.sort { |a,b| order.index(a.id) <=> order.index(b.id) }
      else
        objects
      end
    end

    def count(query)
      index_for(query).count(query)
    end

    def add(*args)
      tables << storage_factory.index(klass, *args)
    end

    def cache(fields, options = {})
      caches << storage_factory.cache(klass, fields, options)
    end

    def create(document)
      each_store { |s| s.create(document) }
    end

    def update(document)
      each_store { |s| s.update(document) }
    end

    def destroy(document)
      stores.reverse.each { |i| i.destroy(document) }
    end

    def create_tables!
      tables.each { |t| table_creator.create(t) }
    end

    def index_for(conditions)
      index = tables.detect { |i| i.satisfies?(conditions) }
      if index.nil?
        raise MissingIndex, "No index found to satisfy: #{conditions.inspect}."
      end
      index
    end

    protected
      def each_store
        stores.each { |s| yield(s) }
      end

      def stores
        tables + caches
      end

      def first_from_cache(query)
        cache = cache_for(query)
        if cache
          cache.first(query) { yield }
        else
          yield
        end
      end

      def cache_for(query)
        caches.detect { |c| c.satisfies?(query) }
      end

      def perform_all(query)
        cache = cache_for(query)
        if cache
          cache.all(query) do |missing_key|
            index_for(query).first(Query.new(:id => missing_key.split("/").last))
          end
        else
          index_for(query).all(query)
        end
      end
  end
end
