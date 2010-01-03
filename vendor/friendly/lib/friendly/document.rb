require 'active_support/inflector'
require 'friendly/associations'

module Friendly
  module Document
    class << self
      attr_writer :documents

      def included(klass)
        documents << klass
        klass.class_eval do
          extend ClassMethods
          attribute :id,         UUID
          attribute :created_at, Time
          attribute :updated_at, Time
        end
      end

      def documents
        @documents ||= []
      end

      def create_tables!
        documents.each { |d| d.create_tables! }
      end
    end

    module ClassMethods
      attr_writer :storage_proxy, :query_klass, 
                  :table_name,    :collection_klass,
                  :scope_proxy,   :association_set

      def create_tables!
        storage_proxy.create_tables!
      end

      def attribute(name, type = nil, options = {})
        attributes[name] = Attribute.new(self, name, type, options)
      end

      def storage_proxy
        @storage_proxy ||= StorageProxy.new(self)
      end

      def query_klass
        @query_klass ||= Query
      end

      def collection_klass
        @collection_klass ||= WillPaginate::Collection
      end

      def indexes(*args)
        storage_proxy.add(args)
      end

      def caches_by(*fields)
        options = fields.last.is_a?(Hash) ? fields.pop : {}
        storage_proxy.cache(fields, options)
      end

      def attributes
        @attributes ||= {}
      end

      def first(query)
        storage_proxy.first(query(query))
      end

      def all(query)
        storage_proxy.all(query(query))
      end

      def find(id)
        doc = first(:id => id)
        raise RecordNotFound, "Couldn't find #{name}/#{id}" if doc.nil?
        doc
      end

      def count(conditions)
        storage_proxy.count(query(conditions))
      end

      def paginate(conditions)
        query      = query(conditions)
        count      = count(query)
        collection = collection_klass.new(query.page, query.per_page, count)
        collection.replace(all(query))
      end

      def create(attributes = {})
        doc = new(attributes)
        doc.save
        doc
      end

      def table_name
        @table_name ||= name.pluralize.underscore
      end

      def scope_proxy
        @scope_proxy ||= ScopeProxy.new(self)
      end

      # Add a named scope to this Document.
      #
      # e.g.
      #     
      #     class Post
      #       indexes     :created_at
      #       named_scope :recent, :order! => :created_at.desc
      #     end
      #
      # Then, you can access the recent posts with:
      #
      #     Post.recent.all
      # ...or...
      #     Post.recent.first
      #
      # Both #all and #first also take additional parameters:
      #
      #     Post.recent.all(:author_id => @author.id)
      #
      # Scopes are also chainable. See the README or Friendly::Scope docs for details.
      #
      # @param [Symbol] name the name of the scope.
      # @param [Hash] parameters the query that this named scope will perform.
      #
      def named_scope(name, parameters)
        scope_proxy.add_named(name, parameters)
      end

      # Returns boolean based on whether the Document has a scope by a particular name.
      #
      # @param [Symbol] name The name of the scope in question.
      #
      def has_named_scope?(name)
        scope_proxy.has_named_scope?(name)
      end

      # Create an ad hoc scope on this Document.
      #
      # e.g.
      #     
      #     scope = Post.scope(:order! => :created_at)
      #     scope.all # => [#<Post>, #<Post>]
      #
      # @param [Hash] parameters the query parameters to create the scope with.
      #
      def scope(parameters)
        scope_proxy.ad_hoc(parameters)
      end

      def association_set
        @association_set ||= Associations::Set.new(self)
      end

      # Add a has_many association.
      #
      # e.g.
      #
      #     class Post
      #       attribute :user_id, Friendly::UUID
      #       indexes   :user_id
      #     end
      #      
      #     class User
      #       has_many :posts
      #     end
      #     
      #     @user = User.create
      #     @post = @user.posts.create
      #     @user.posts.all == [@post] # => true
      #
      # _Note: Make sure that the target model is indexed on the foreign key. If it isn't, querying the association will raise Friendly::MissingIndex._
      #
      # Friendly defaults the foreign key to class_name_id just like ActiveRecord.
      # It also converts the name of the association to the name of the target class just like ActiveRecord does.
      #
      # The biggest difference in semantics between Friendly's has_many and active_record's is that Friendly's just returns a Friendly::Scope object. If you want all the associated objects, you have to call #all to get them. You can also use any other Friendly::Scope method.
      #
      # @param [Symbol] name The name of the association and plural name of the target class.
      # @option options [String] :class_name The name of the target class of this association if it is different than the name would imply.
      # @option options [Symbol] :foreign_key Override the foreign key.
      # 
      def has_many(name, options = {})
        association_set.add(name, options)
      end

      protected
        def query(conditions)
          conditions.is_a?(Query) ? conditions : query_klass.new(conditions)
        end
    end

    def initialize(opts = {})
      self.attributes = opts
    end

    def attributes=(attrs)
      assert_no_duplicate_keys(attrs)
      attrs.each { |name, value| send("#{name}=", value) }
    end

    def save
      new_record? ? storage_proxy.create(self) : storage_proxy.update(self)
    end

    def update_attributes(attributes)
      self.attributes = attributes
      save
    end

    def destroy
      storage_proxy.destroy(self)
    end

    def to_hash
      Hash[*self.class.attributes.keys.map { |n| [n, send(n)] }.flatten]
    end

    def table_name
      self.class.table_name
    end

    def new_record?
      new_record
    end

    def new_record
      @new_record = true if @new_record.nil?
      @new_record
    end

    def new_record=(value)
      @new_record = value
    end

    def storage_proxy
      self.class.storage_proxy
    end

    def ==(comparison_object)
      comparison_object.equal?(self) ||
        (comparison_object.is_a?(self.class) &&
          !comparison_object.new_record? && 
            comparison_object.id == id)
    end

    protected
      def assert_no_duplicate_keys(hash)
        if hash.keys.map { |k| k.to_s }.uniq.length < hash.keys.length
          raise ArgumentError, "Duplicate keys: #{hash.inspect}"
        end
      end
  end
end
