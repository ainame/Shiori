module SingletonClass
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def new
      super
      instance
    end

    def instance
      Dispatch.once { @instance ||= alloc.init }
      @instance
    end
  end
end
