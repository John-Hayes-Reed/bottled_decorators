require 'spec_helper'
require 'json'
describe BottledDecorators do
  it 'has a version number' do
    expect(BottledDecorators::VERSION).not_to be nil
  end
end

describe BottledDecorator do
  subject(:decorated){
    class ExampleDecoratedClass
      attr_accessor :attributes, :first_name, :last_name

      def initialize(attributes = {first_name: 'John', last_name: 'Hayes-Reed'})
        @attributes = attributes
        attributes.each do |att, val|
          self.send("#{att}=", val)
        end
      end

      def example_method
        "This is an example"
      end

      def example_with_parameters(a_param)
        return true if a_param
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

      def display_test_var
        @test_var
      end
    end
    ExampleDecoratorClass.(decorated, test_var: 'This is a test variable')
  }
  subject(:stacking_decorator){
    class StackingDecoratorClass
      include BottledDecorator

      def example_method
        super + " within an example"
      end

      def full_name_reverse
        "#{last_name} #{first_name}"
      end
    end
    StackingDecoratorClass.(decorator)
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

    it 'is stackable for multiple decorator layers' do
      expect(stacking_decorator.example_method).to eql("This is an example within an example within an example")
    end

    it 'can access the components original methods from stacked decorator' do
      expect(stacking_decorator.full_name_reverse).to eql("Hayes-Reed John")
    end

    it 'can access child decorators methods' do
      expect(stacking_decorator.full_name).to eql("John Hayes-Reed")
    end

    it "is able to accept direct calls to the components methods from the stacked decorator" do
      expect(stacking_decorator.last_name).to eql("Hayes-Reed")
    end

    it "can accept additional option variables" do
      expect(decorator.display_test_var).to eql("This is a test variable")
    end

    it "can access additional option variables from the stacked decorator" do
      expect(stacking_decorator.display_test_var).to eql("This is a test variable")
    end

    it "can access the components original methods with parameters" do
      expect(decorator.example_with_parameters("parameter")).to eql(true)
    end
  end
end
