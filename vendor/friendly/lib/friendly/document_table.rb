require 'friendly/table'

module Friendly
  class DocumentTable < Table
    attr_reader :klass, :translator

    def initialize(klass, datastore=Friendly.datastore, translator=Translator.new)
      super(datastore)
      @klass      = klass
      @translator = translator
    end

    def table_name
      klass.table_name
    end

    def satisfies?(query)
      query.conditions.keys == [:id] && !query.order
    end

    def create(document)
      record = translator.to_record(document)
      datastore.insert(document, record)
      update_document(document, record)
    end

    def update(document)
      record = translator.to_record(document)
      datastore.update(document, document.id, record)
      update_document(document, record)
    end

    def destroy(document)
      datastore.delete(document, document.id)
    end

    def first(query)
      record = datastore.first(klass, query)
      record && to_object(record)
    end

    def all(query)
      datastore.all(klass, query).map { |r| to_object(r) }
    end

    protected
      def update_document(document, record)
        attrs = record.reject { |k,v| k == :attributes }.merge(:new_record => false)
        document.attributes = attrs
      end

      def to_object(record)
        translator.to_object(klass, record)
      end
  end
end
