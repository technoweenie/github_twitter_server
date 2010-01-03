module Friendly
  class StorageFactory
    attr_reader :table_klass, :index_klass, :cache_klass

    def initialize(table_klass = DocumentTable, index_klass = Index,
                   cache_klass = Cache)
      @table_klass = table_klass
      @index_klass = index_klass
      @cache_klass = cache_klass
    end

    def document_table(*args)
      table_klass.new(*args)
    end

    def index(*args)
      index_klass.new(*args)
    end

    def cache(*args)
      cache_klass.cache_for(*args)
    end
  end
end
