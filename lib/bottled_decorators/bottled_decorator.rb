module BottledDecorator

  def self.included(base)
    base.extend(ClassMethods)
  end

  def initialize(component, **options)
    class << self
      attr_reader :component
    end
    @component = component
    options.each do |option_key, option_val|
      self.instance_variable_set("@#{option_key}", option_val)
    end
  end

  def method_missing(method, *args)
    return @component.send(method, *args)
  rescue NoMethodError => e
    raise NoMethodError.new("Method #{method} was not found in the decorator, or the decorated objects", 'NoMethodError')
  end

  def as_json(**args)
    to_h(**args).as_json
  end

  def to_json(**args)
    to_h(**args).to_json
  end

  def to_h(**args)
    {}.tap do |hash|
      if @component.respond_to?(:component)
        hash.merge!(@component.to_h(args))
      else
        hash.merge!(@component.as_json(args))
      end
      self.class.instance_methods(false).each do |m|
        hash["#{m}"] = send(m)
      end
    end
  end

  module ClassMethods
    def call(*args)
      new(*args)
    end
  end

end
