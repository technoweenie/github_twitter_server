require 'friendly/scope'

module Friendly
  class NamedScope
    attr_reader :klass, :parameters, :scope_klass

    def initialize(klass, parameters, scope_klass = Scope)
      @klass       = klass
      @parameters  = parameters
      @scope_klass = scope_klass
    end

    def scope
      @scope_klass.new(@klass, @parameters)
    end
  end
end
