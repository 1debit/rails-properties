# Properties for Rails

Ruby gem to handle properties for ActiveRecord instances by storing them as serialized Hash in a separate database table. Namespaces and defaults included.

## Requirements

* Ruby 1.9.3 or newer
* Rails 3.1 or newer (including Rails 5.2)


## Installation

Include the gem in your Gemfile and run `bundle` to install it:

```ruby
gem 'rails-properties'
```

Generate and run the migration:

```shell
rails g rails_properties:migration
rake db:migrate
```


## Usage

### Define properties

```ruby
class User < ActiveRecord::Base
  has_properties do |s|
    s.key :dashboard, :defaults => { :theme => 'blue', :view => 'monthly', :filter => false }
    s.key :calendar,  :defaults => { :scope => 'company'}
  end
end
```

If no defaults are needed, a simplified syntax can be used:

```ruby
class User < ActiveRecord::Base
  has_properties :dashboard, :calendar
end
```

Every property is handled by the class `RailsProperties::PropertyObject`. You can use your own class, e.g. for validations:

```ruby
class Project < ActiveRecord::Base
  has_properties :info, :class_name => 'ProjectPropertyObject'
end

class ProjectPropertyObject < RailsProperties::PropertyObject
  validate do
    unless self.owner_name.present? && self.owner_name.is_a?(String)
      errors.add(:base, "Owner name is missing")
    end
  end
end
```

### Set properties

```ruby
user = User.find(1)
user.properties(:dashboard).theme = 'black'
user.properties(:calendar).scope = 'all'
user.properties(:calendar).display = 'daily'
user.save! # saves new or changed properties, too
```

or

```ruby
user = User.find(1)
user.properties(:dashboard).update_attributes! :theme => 'black'
user.properties(:calendar).update_attributes! :scope => 'all', :display => 'daily'
```


### Get properties

```ruby
user = User.find(1)
user.properties(:dashboard).theme
# => 'black

user.properties(:dashboard).view
# => 'monthly'  (it's the default)

user.properties(:calendar).scope
# => 'all'
```

### Delete properties

```ruby
user = User.find(1)
user.properties(:dashboard).update_attributes! :theme => nil

user.properties(:dashboard).view = nil
user.properties(:dashboard).save!
```

### Using scopes

```ruby
User.with_properties
# => all users having any property

User.without_properties
# => all users without having any property

User.with_properties_for(:calendar)
# => all users having a property for 'calender'

User.without_properties_for(:calendar)
# => all users without having properties for 'calendar'
```

### Eager Loading
```ruby
User.includes(:property_objects)
# => Eager load property_objects when querying many users
```

## License

MIT License

Copyright (c) 2012-2018 [Georg Ledermann](http://www.georg-ledermann.de)

This gem is a rename of [rails-settings](https://github.com/ledermann/rails-settings) by [Georg Ledermann](https://github.com/ledermann)
