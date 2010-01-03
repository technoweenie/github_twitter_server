require 'friendly/table'

module Friendly
  class Index < Table
    attr_reader :klass, :fields, :datastore

    def initialize(klass, fields, datastore = Friendly.datastore)
      @klass     = klass
      @fields    = fields
      @datastore = datastore
    end

    def table_name
      ["index", klass.table_name, "on", fields.join("_and_")].join("_")
    end

    def satisfies?(query)
      exact_match?(query) || valid_partial_match?(query)
    end

    def first(query)
      row = datastore.first(self, query)
      row && klass.first(:id => row[:id])
    end

    def all(query)
      ids = datastore.all(self, query).map { |row| row[:id] }
      klass.all(:id => ids, :preserve_order! => !query.order.nil?)
    end

    def count(query)
      datastore.count(self, query)
    end

    def create(document)
      datastore.insert(self, record(document))
    end

    def update(document)
      datastore.update(self, document.id, record(document))
    end

    def destroy(document)
      datastore.delete(self, document.id)
    end

    protected
      def exact_match?(query)
        query.conditions.keys.map { |f| f.to_s }.sort == 
          fields.map { |f| f.to_s }.sort && 
            valid_order?(query.order)
      end

      def valid_partial_match?(query)
        condition_fields = query.conditions.keys
        sorted = condition_fields.sort { |a,b| field_index(a) <=> field_index(b) }
        sorted << query.order.expression if query.order
        sorted.zip(fields).all? { |a,b| a == b }
      end

      def valid_order?(order)
        order.nil? || order.expression == fields.last
      end

      def field_index(attr)
        fields.index(attr) || 0
      end

      def record(document)
        Hash[*(fields + [:id]).map { |f| [f, document.send(f)] }.flatten]
      end
  end
end
