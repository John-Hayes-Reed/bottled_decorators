module BottledDecorator

  def self.included(base)
    base.extend(ClassMethods)
  end

  def initialize(component, **options)
    @component = component
    options.each do |option_key, option_val|
      self.instance_variable_set("@#{option_key}", option_val)
    end
  end

  def method_missing(method, *args)
    send :define_singleton_method, method do
      return @component.send(method)
    end
    self.send(method)
  rescue NoMethodError => e
    raise NoMethodError.new("Method #{method} was not found in the decorator, or the decorated objects", 'NoMethodError')
  end

  module ClassMethods
    def call(*args)
      new(*args)
    end
  end

end
