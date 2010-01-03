module Friendly
  class Query
    attr_reader :conditions, :limit, :order, 
                :preserve_order, :offset, :uuid_klass,
                :page, :per_page

    def initialize(parameters, uuid_klass = UUID)
      @uuid_klass = uuid_klass
      @conditions = parameters.reject { |k,v| k.to_s =~ /!$/ }
      @page       = (parameters[:page!] || 1).to_i
      
      [:per_page!, :limit!, :offset!, :order!, :preserve_order!].each do |p|
        instance_variable_set("@#{p.to_s.gsub(/!/, '')}", parameters[p])
      end

      handle_pagination if per_page
      convert_ids_to_uuids
    end

    def preserve_order?
      preserve_order
    end

    def offset?
      offset
    end

    protected
      def convert_ids_to_uuids
        if conditions[:id] && conditions[:id].is_a?(Array)
          conditions[:id] = conditions[:id].map { |i| uuid_klass.new(i) }
        elsif conditions[:id]
          conditions[:id] = uuid_klass.new(conditions[:id])
        end
      end

      def handle_pagination
        @limit  = per_page
        @offset = (page - 1) * per_page
      end
  end
end
