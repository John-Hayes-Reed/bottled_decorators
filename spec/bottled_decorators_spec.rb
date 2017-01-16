require 'spec_helper'

describe BottledDecorators do
  it 'has a version number' do
    expect(BottledDecorators::VERSION).not_to be nil
  end
end

describe BottledDecorator do
  subject(:decorated){
    class ExampleDecoratedClass

      def example_method
        "This is an example"
      end

      def first_name
        "John"
      end

      def last_name
        "Hayes-Reed"
      end

    end
    ExampleDecoratedClass.new
  }
  subject(:decorator){
    class ExampleDecoratorClass
      include BottledDecorator

      def example_method
        super + " within an example"
      end

      def full_name
        "#{first_name} #{last_name}"
      end
    end
    ExampleDecoratorClass.new(decorated) #TODO: fix the NoMethodError call problem
  }
  describe '#new' do
    it 'responds to overridden messages' do
      expect(decorator.example_method).to eql("This is an example within an example")
    end

    it 'accesses the components original methods from decorator methods' do
      expect(decorator.full_name).to eql("John Hayes-Reed")
    end

    it 'is able to accept direct calls to the components methods' do
      expect(decorator.last_name).to eql("Hayes-Reed")
    end
  end
end
