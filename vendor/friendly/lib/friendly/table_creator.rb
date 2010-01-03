module Friendly
  class TableCreator
    attr_reader :db, :attr_klass

    def initialize(db = Friendly.db, attr_klass = Friendly::Attribute)
      @db         = db
      @attr_klass = attr_klass
    end

    def create(table)
      unless db.table_exists?(table.table_name)
        case table
        when DocumentTable
          create_document_table(table) 
        when Index
          create_index_table(table)
        end
      end
    end

    protected
      def create_document_table(table)
        db.create_table(table.table_name) do
          primary_key :added_id
          column      :id, :bytea
          String      :attributes, :text => true
          Time        :created_at
          Time        :updated_at
        end
      end

      def create_index_table(table)
        attr = attr_klass # close around this please

        db.create_table(table.table_name) do
          column      :id, :bytea
          table.fields.flatten.each do |f|    
            klass = table.klass.attributes[f].type
            type  = attr.custom_type?(klass) ? attr.sql_type(klass) : klass
            column(f, type)
          end
          primary_key table.fields.flatten + [:id]
          unique :id
        end
      end
  end
end

