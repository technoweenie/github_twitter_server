require 'friendly/named_scope'

module Friendly
  class ScopeProxy
    attr_reader :klass, :scope_klass, :scopes

    def initialize(klass, scope_klass = Scope)
      @klass       = klass
      @scope_klass = scope_klass
      @scopes      = {}
    end

    def add_named(name, parameters)
      scopes[name] = parameters
      add_scope_method_to_klass(name)
    end

    def get(name)
      scopes[name]
    end

    def get_instance(name)
      scope_klass.new(klass, get(name))
    end

    def ad_hoc(parameters)
      scope_klass.new(klass, parameters)
    end

    def has_named_scope?(name)
      scopes.has_key?(name)
    end

    protected
      def add_scope_method_to_klass(scope_name)
        klass.class_eval do
          eval <<-__END__
            def self.#{scope_name}
              scope_proxy.get_instance(:#{scope_name})
            end
          __END__
        end
      end
  end
end
