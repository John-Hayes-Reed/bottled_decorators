# Public: A module to turn classes into bottled decorators, for the decorator
# design pattern, wrapping a component with new functionality, while still
# allowing the original functionality and access for the wrapped component.
module BottledDecorator
  # Internal: Runs when the module is included, makes the including class extend
  # The ClassMethod module below to include a class ::call method.
  #
  # Returns nothing.
  def self.included(base)
    base.extend(ClassMethods)
  end

  # Internal: initializes a new decorator instance. Sets the component and
  # options attibutes and reader methods for each.
  #
  # Returns nothing.
  def initialize(component, **options)
    class << self
      attr_reader :component
    end
    @component = component
    options.each do |option_key, option_val|
      (class << self; self; end).class_eval { attr_reader option_key }
      self.instance_variable_set(:"@#{option_key}", option_val)
    end
  end

  # Internal: Sends any method requests unknown to the decorator back down to
  # the component. This allows the wrapped instances to still use the inner
  # components methods as if they were being called on the original component
  # before wrapping.
  #
  # Examples
  #
  #   @user.name
  #   # => 'John'
  #   @decorated_user = ExampleDecorator.call @user
  #   @decorated_user.name
  #   # => 'John'
  def method_missing(method, *args)
    return @component.send(method, *args)
  rescue NoMethodError => e
    raise NoMethodError.new("Method #{method} was not found in the decorator, or the decorated objects", 'NoMethodError')
  end

  # Public: Takes the decorated component and serializes it into a JSON format
  # by combining its original attributes and the decorated methods from the
  # wrapping decorator class.
  #
  # Returns a JSON object representation of the decorated component.
  def as_json(**args)
    to_h(**args).as_json
  end

  # Public: Takes the decorated component and serializes it into a JSON format
  # by combining its original attributes and the decorated methods from the
  # wrapping decorator class.
  #
  # Returns a JSON object representation of the decorated component.
  def to_json(**args)
    to_h(**args).to_json
  end

  # Public: Takes the decorated component and serializes it into a Hash format
  # by combining its original attributes and the decorated methods from the
  # wrapping decorator class.
  #
  # Examples
  #
  #   @user.to_h
  #   # => { first_name: 'John', last_name: 'Hayes-Reed' }
  #   @decorated_user = FullNameDecorator.call @user
  #   @decorated_user.to_h
  #   # => { first_name: 'John',
  #          last_name: 'Hayes-Reed',
  #          full_name: 'John Hayes-Reed' }
  #
  # Returns a Hash object representation of the decorated component.
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

  # Public: checks if either the decorator class, or the decorated component
  # Responds to a method.
  #
  # Examples
  #
  #   @user.respond_to? :name
  #   # => true
  #   @user.respond_to? :full_name
  #   # => false
  #
  #   @decorated_user = FullNameDecorator.call @user
  #   @decorated_user.respond_to? :name
  #   # => true
  #   @decorated_user.respond_to? :full_name
  #   # => true
  def respond_to?(tester)
    response = @component.respond_to?(tester)
    return true if response
    self.class.instance_methods(false).map(&:to_s).include?("#{tester}")
  end

  # Public: Uses the decorated components #to_param method as its own. This
  # allows for the natural use of decorated objects in things like Rails url
  # helper methods.
  #
  # Returns the components parameter attibute. (eg: id).
  def to_param
    @component.to_param
  end

  # Public: Gets the root component in the case of multiple wrapped components
  # by first searching if the current decorators component itself holds a
  # component.
  #
  # Examples
  #
  #   decorated_user.root_component
  #   # => #<User:00x0...>
  #
  # Returns whichever is the lowest component in the stack.
  def root_component
    return @component.root_component if @component.respond_to? :component
    @component
  end

  # Internal: Allows methods found in the decorator, as well as methods found
  # in the original decorated component to be recognised by #method method.
  #
  # Returns a Method object if found.
  private def respond_to_missing?(method, include_private = false)
    @component.respond_to?(method) ||
      self.class.instance_methods(false).map(&:to_s).include?(method.to_s) ||
      super
  end

  # Internal: The class methods to be added to the decorator class when
  # including this module. Adds a class ::call method.
  module ClassMethods
    # Public: instantiates a new decorator class instance, creates an Array
    # of instances if the first argument (the component), is an iterable
    # group of objects.
    #
    # Returns a decorated object, or an Array of decorated objects.
    def call(*args)
      if args.first.respond_to?(:each)
        [].tap do |arr|
          args.first.each do |comp|
            arr << new(*([comp, args[1..-1]].flatten))
          end
        end
      else
        new(*args)
      end
    end
  end
end
