require 'rails/generators'
class BottledDecoratorGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  argument :attributes, type: :array, default: []

  def generate_bottled_service
    puts "Generating Bottled Decorator: #{name}"
    create_file "app/decorators/#{file_name}.rb", <<-File
class #{class_name}
  include BottledDecorator

  #{ "".tap do |str|
      attributes.each do |attribute|
        puts "injecting method: #{attribute.name}"
          str << "
  def #{attribute.name}
    # access the decorated object through the @component instance variable
    # note, you dont need to call methods of the component in the instance variable.
    # if your decorated model or class has a user_name method, you can just call user_name.
  "
      end
    end
}

end
    File
  end
end
