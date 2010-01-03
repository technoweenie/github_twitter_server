module Friendly
  class Scope
    attr_reader :klass, :parameters

    def initialize(klass, parameters)
      @klass      = klass
      @parameters = parameters
    end

    # Fetch all documents at this scope.
    #
    # @param [Hash] extra_parameters add extra parameters to this query.
    #
    def all(extra_parameters = {})
      klass.all(params(extra_parameters))
    end

    # Fetch the first document at this scope.
    #
    # @param [Hash] extra_parameters add extra parameters to this query.
    #
    def first(extra_parameters = {})
      klass.first(params(extra_parameters))
    end

    # Paginate the documents at this scope.
    #
    # @param [Hash] extra_parameters add extra parameters to this query.
    # @return WillPaginate::Collection
    #
    def paginate(extra_parameters = {})
      klass.paginate(params(extra_parameters))
    end

    # Build an object at this scope.
    #
    #   e.g.
    #     Post.scope(:name => "James").build.name # => "James"
    #
    # @param [Hash] extra_parameters add extra parameters to this query.
    #
    def build(extra_parameters = {})
      klass.new(params_without_modifiers(extra_parameters))
    end

    # Create an object at this scope.
    #
    #   e.g.
    #     @post = Post.scope(:name => "James").create
    #     @post.new_record? # => false
    #     @post.name # => "James"
    #
    # @param [Hash] extra_parameters add extra parameters to this query.
    #
    def create(extra_parameters = {})
      klass.create(params_without_modifiers(extra_parameters))
    end

    # Override #respond_to? so that we can return true when it's another named_scope.
    #
    # @override
    #
    def respond_to?(method_name, include_private = false)
      klass.has_named_scope?(method_name) || super
    end

    # Use method_missing to respond to other named scopes on klass.
    # 
    # @override
    #
    def method_missing(method_name, *args, &block)
      respond_to?(method_name) ? chain_with(method_name) : super
    end

    # Chain with another one of klass's named_scopes.
    #
    # @param [Symbol] scope_name The name of the scope to chain with.
    #
    def chain_with(scope_name)
      self + klass.send(scope_name)
    end

    # Create a new Scope that is the combination of self and other, where other takes priority
    #
    # @param [Friendly::Scope] other The scope to merge with.
    #
    def +(other_scope)
      self.class.new(klass, parameters.merge(other_scope.parameters))
    end

    protected
      def params(extra)
        parameters.merge(extra)
      end

      def params_without_modifiers(extra)
        params(extra).reject { |k,v| k.to_s =~ /!$/ }
      end
  end
end
