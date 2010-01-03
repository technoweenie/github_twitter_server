module Friendly
  class Storage
    def create(document)
      raise NotImplementedError, "#{self.class.name}#create is not implemented."
    end

    def update(document)
      raise NotImplementedError, "#{self.class.name}#update is not implemented."
    end

    def destroy(document)
      raise NotImplementedError, "#{self.class.name}#destroy is not implemented."
    end

    def first(conditions)
      raise NotImplementedError, "#{self.class.name}#first is not implemented."
    end

    def all(conditions)
      raise NotImplementedError, "#{self.class.name}#all is not implemented."
    end

    def count(query)
      raise NotImplementedError, "#{self.class.name}#count is not implemented."
    end

    def satisfies?(conditions)
      raise NotImplementedError, "#{self.class.name}#satisfies? is not implemented."
    end
  end
end
