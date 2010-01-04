module Friendly
  module Associations
    class Association
      attr_reader :owner_klass, :name

      def initialize(owner_klass, name, options = {})
        @owner_klass = owner_klass
        @name        = name
        @class_name  = options[:class_name]
        @foreign_key = options[:foreign_key]
      end

      def klass
        @klass ||= class_name.constantize
      end

      def foreign_key
        @foreign_key ||= [owner_klass_name, :id].join("_").to_sym
      end

      def class_name
        @class_name ||= name.to_s.classify
      end

      def owner_klass_name
        owner_klass.name.to_s.underscore.singularize
      end

      def scope(document)
        klass.scope(foreign_key => document.id)
      end
    end
  end
end
