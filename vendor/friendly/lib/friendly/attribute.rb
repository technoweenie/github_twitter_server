module Friendly
  class Attribute
    class << self
      def register_type(type, sql_type, &block)
        sql_types[type.name] = sql_type
        converters[type]     = block
      end

      def deregister_type(type)
        sql_types.delete(type.name)
        converters.delete(type)
      end
        
      def sql_type(type)
        sql_types[type.name]
      end

      def sql_types
        @sql_types ||= {}
      end

      def converters
        @converters ||= {}
      end

      def custom_type?(klass)
        !sql_type(klass).nil?
      end
    end

    converters[Integer] = lambda { |s| s.to_i }
    converters[String]  = lambda { |s| s.to_s }
    
    attr_reader :klass, :name, :type, :default_value

    def initialize(klass, name, type, options = {})
      @klass         = klass
      @name          = name
      @type          = type
      @default_value = options[:default]
      build_accessors
    end

    def typecast(value)
      !type || value.is_a?(type) ? value : convert(value)
    end

    def convert(value)
      assert_converter_exists(value)
      converters[type].call(value)
    end

    def default
      if !default_value.nil?
        default_value
      elsif type.respond_to?(:new)
        type.new
      else
        nil
      end
    end
      
    protected
      def build_accessors
        n = name
        klass.class_eval do
          eval <<-__END__
            def #{n}=(value)
              @#{n} = self.class.attributes[:#{n}].typecast(value)
            end

            def #{n}
              @#{n} ||= self.class.attributes[:#{n}].default
            end
          __END__
        end
      end

      def assert_converter_exists(value)
        unless converters.has_key?(type)
          msg = "Can't convert #{value} to #{type}. 
                 Add a custom converter to Friendly::Attribute::CONVERTERS."
          raise NoConverterExists, msg
        end
      end

      def converters
        self.class.converters
      end
  end
end
