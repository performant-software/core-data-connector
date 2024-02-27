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

## Public API

In addition to the authenticated API, the `core_data_connector` gem also provides a public API for the following endpoints:

```
GET /core_data/public/instances
GET /core_data/public/instances/:uuid
GET /core_data/public/instances/:uuid/instances
GET /core_data/public/instances/:uuid/items
GET /core_data/public/instances/:uuid/manifests
GET /core_data/public/instances/:uuid/manifests/:uuid
GET /core_data/public/instances/:uuid/media_contents
GET /core_data/public/instances/:uuid/organizations
GET /core_data/public/instances/:uuid/people
GET /core_data/public/instances/:uuid/places
GET /core_data/public/instances/:uuid/taxonomies
GET /core_data/public/instances/:uuid/works
```

```
GET /core_data/public/items
GET /core_data/public/items/:uuid
GET /core_data/public/items/:uuid/instances
GET /core_data/public/items/:uuid/items
GET /core_data/public/items/:uuid/manifests
GET /core_data/public/items/:uuid/manifests/:uuid
GET /core_data/public/items/:uuid/media_contents
GET /core_data/public/items/:uuid/organizations
GET /core_data/public/items/:uuid/people
GET /core_data/public/items/:uuid/places
GET /core_data/public/items/:uuid/taxonomies
GET /core_data/public/items/:uuid/works
```

```
GET /core_data/public/places
GET /core_data/public/places/:uuid
GET /core_data/public/places/:uuid/instances
GET /core_data/public/places/:uuid/items
GET /core_data/public/places/:uuid/manifests
GET /core_data/public/places/:uuid/manifests/:uuid
GET /core_data/public/places/:uuid/media_contents
GET /core_data/public/places/:uuid/organizations
GET /core_data/public/places/:uuid/people
GET /core_data/public/places/:uuid/places
GET /core_data/public/places/:uuid/taxonomies
GET /core_data/public/places/:uuid/works
```

```
GET /core_data/public/works
GET /core_data/public/works/:uuid
GET /core_data/public/works/:uuid/instances
GET /core_data/public/works/:uuid/items
GET /core_data/public/works/:uuid/manifests
GET /core_data/public/works/:uuid/manifests/:uuid
GET /core_data/public/works/:uuid/media_contents
GET /core_data/public/works/:uuid/organizations
GET /core_data/public/works/:uuid/people
GET /core_data/public/works/:uuid/places
GET /core_data/public/works/:uuid/taxonomies
GET /core_data/public/works/:uuid/works
```

The following query parameters can be used to further modify the results:

| Parameter   | Description                                      | Required |
|-------------|--------------------------------------------------|----------|
| project_ids | An array of project IDs                          | Yes      |
| search      | Search text used to filter the records           | No       |
| sort_by     | A database colum name to use for sorting records | No       |

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