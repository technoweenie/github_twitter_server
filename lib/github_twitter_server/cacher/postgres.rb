# hacks to get Friendly to work with PSQL
module Friendly
  class TableCreator
    protected
      def create_document_table(table)
        db.create_table(table.table_name) do
          primary_key :added_id
          String      :id,         :size => 16
          String      :attributes, :text => true
          Time        :created_at
          Time        :updated_at
        end
      end

      def create_index_table(table)
        attr = attr_klass # close around this please

        db.create_table(table.table_name) do
          String :id, :size => 16
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

