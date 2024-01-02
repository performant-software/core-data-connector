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
$ bundle install
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
$ bundle exec rails g core_data_connector:install
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

## Release

To release a new version of the `core_data_connector` gem in GitHub, use the following steps:

1. Create a new release in GitHub. Document any breaking changes, new features, or bug fixes (see existing releases for examples). Tag the release with a new version (see below).
2. Update the "next release" label to the new version number. Any PRs included in the release should have been tagged with the "next release" label.
3. Create a new "next release" label.

#### Versioning
Version numbers are based on the [Semantic Versioning](https://semver.org/) spec: [Major].[Minor].[Patch] (i.e. 3.4.118). The following guidelines should be used to determine which number to increment:

- **Patch:** Small bug fixes, minimal new features 
- **Minor:** Larger features, some breaking changes with backwards compatibility
- **Major:** Large features, breaking changes with no backwards compatibility


## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).