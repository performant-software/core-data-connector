# CoreDataConnector
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "core_data_connector"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install core_data_connector
```

## Migrations
This gem can be used in one of two ways:
1. As the basis for an application designed to _store_ core data
2. As a utility for an application looking to _integrate_ core data

If your application will have local tables to represent core data (#1 above), use the following command to install the necessary migrations.

```bash
$ bundle exec rails core_data_connector:install:migrations
```

## Overlay
There will be situations where you'll want to extend the models provided by this gem, to add validations, relate to other models, etc. In order to accomplish this, you can provide extensions in the form on concerns and apply them inside the `core_data_connector` initializer.

```ruby
# /lib/extensions/core_data_connector/place_validations.rb

module Extensions
  module CoreDataConnector
    module PlaceValidations
      extend ActiveSupport::Concern
      
      included do
        validates :validate_something
        
        def validate_something
          # Do validation here
        end
      end
    end
  end
end
```

In the `core_data_connector` initializer, include the extension in the place model.

```ruby
# /initializers/core_data_connector.rb

Rails.application.config.to_prepare do
  CoreDataConnector::Place.include(Extensions::CoreDataConnector::PlaceValidations)
end
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
