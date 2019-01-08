# BottledDecorators

bottled_decorators are here to make your life easier, and provide decorators that are actually decorators and not just View Objects / View Helpers with the name 'decorator'. bottled_decorators encourage the use of DRY and reusable code by stopping the direct model relation and 'my job is to prepare something for the view' mentality seen in some gems and implementations, and to bring decorators back to what they should be, a reusable and stackable extra layer of functionality to be used **anywhere** and not just in views.
Creating your decorators are also as easy as pie with the botted_decorator generator. All you need to worry about is your method logic, let bottled_decorators do the rest for you!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bottled_decorators'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bottled_decorators

## Usage

#### Giving birth to decorators

Creating new decorators is as easy as pie with the BottledDecorator Generator.
just add the decorator name, and if you want the decorator methods, to the generator command:

```
rails g bottled_decorator LargeFoodItem
```

```
rails g bottled_decorator PiratizedUser name greeting
```

Just like that we have two new decorators ready for use, a currently empty decorator for decorating food as large food items, and a decorator with two methods prepared for us, name and greeting, that decorates users with pirate like behaviour.

#### Decorator Methods

A possible implementation of the two decorators we generated above could be:

```ruby
class LargeFoodItem
  include BottledDecorator

  # A large food item has 50 cents added onto its cost
  def cost
    super + 50
  end

end
```
```ruby
class PiratizedUser
  include BottledDecorator

  # Pirates all dream of being the captain of their own ship
  def name
    "Cap'n #{super}"
  end

  # And its a well studied fact that Rum is a pirates poison of choice
  def greeting
    "Yo ho ho and a bottle of rum!"
  end

end
```

#### A Decorator's first steps

Once generated, the next things to do is decorate loads of stuff!

Unlike some other implementations of decorators (many of which I dare to say are not actually decorators but just View Objects / Helpers that are hijacking the word *decorator*), BottledDecorators do not use an extension style of decorating. Instead they wrap up our objects in a lovely cosy blanket of decoration:

```ruby
pirate_user = PiratizedUser.call(@user)

# or

@large_burger = LargeFoodItem.call(burger)
```

You can also wrap a collection, to get an Array of decorated objects:

```ruby
@pirates = PiratizedUser.call(@users)
# returns an Array
```

As can be seen above, this wrapping is done using the decorator class' `::call` method.

#### Bottled Decorators in action

Once we have our decorated object, its just a case of invoking your methods:

```ruby
@user.name
# => "John Hayes-Reed"
@user.age
# => 100

@user = PiratizedUser.call(@user)
@user.name
# => "Cap'n John Hayes-Reed"
@user.greeting
# => "Yo ho ho and a bottle of rum!"

# of course we can still access the components original methods as well
@user.age
# => 100
```

Because BottledDecorators wrap instead of extend, we can also keep wrapping on multiple layers, adding on functionality to overridden methods indefinately, because each layer looks at its own component for its `super`, and not the original instance:

```ruby
class DrunkUser
  include BottledDecorator

  def name
    "#{super}, the drunkard!"
  end

  def greeting
    "#{super} (hiccup)"
  end
end
```

```ruby
@user.name
# => "John Hayes-Reed"

@user = PiratizedUser.call(@user)
@user.name
# => "Cap'n John Hayes-Reed"
@user.greeting
# => "Yo ho ho and a bottle of rum!"

@user = DrunkUser.call(@user)
@user.name
# => "Cap'n John Hayes-Reed, the drunkard!"
@user.greeting
# => "Yo ho ho and a bottle of rum! (hiccup)"
```

Because of this layering ability, we can use a single decorator to represent multiple possible states of objects:

```ruby
# a regular burger
@burger.cost
# => 100

# a large burger
LargeFoodItem.call(@burger).cost
# => 150

# an extra large burger
LargeFoodItem.call(LargeFoodItem.call(@burger)).cost
# => 200

# SUPERSIIIIIZE
LargeFoodItem.call(LargeFoodItem.call(LargeFoodItem.call(@burger))).cost
# => 250
```

This can be done with multiple decorators to build up the cost of a whole variety of possibilites:

```ruby
class WithDrink
  include BottledDecorator

  def cost
    super + 15
  end

end
```

```ruby
# a regular burger
@burger.cost
# => 100

# with a side order drink
WithDrink.call(@burger).cost
# => 115

# a large burger with a side order drink
LargeFoodItem.call(WithDrink.call(@burger)).cost
# => 165
```

#### Extras

Currently BottledDecorators come with a few serializer methods and checker methods to add all decorated methods onto the converted object as well, currently supported are `#to_json`, `#as_json`, `#to_h`, `#respond_to?`, each of which will drill down through each component layer all the way to the root component to provide / access the whole scope available.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

All and any contributions to improve Bottled Decorators and make them useful for as many people as possible are gratefully welcomed. I hope all contributions can keep in line with the philosophy of Bottled Technology, which is to make simple and easy-to-use tools.

Bug reports and pull requests are welcome on GitHub at https://github.com/John-Hayes-Reed/bottled_decorators. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
