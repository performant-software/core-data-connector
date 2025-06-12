require_relative 'lib/core_data_connector/version'

Gem::Specification.new do |spec|
  spec.name        = 'core_data_connector'
  spec.version     = CoreDataConnector::VERSION
  spec.authors     = ['Performant Software Solutions']
  spec.email       = ['derek@performantsoftware.com']
  spec.homepage    = 'https://github.com/performant-software/core-data-connector'
  spec.summary     = 'Digitial humanities data. In the cloud.'
  spec.description = 'Bringing digital humanities data into your Rails application.'
  spec.license     = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'faker'
  spec.add_dependency 'rails', '>= 6.0.3.2', '< 8'
  spec.add_dependency 'activerecord-postgis-adapter', '~> 8.0'
  spec.add_dependency 'fuzzy_dates'
  spec.add_dependency 'jwt', '~> 2.7.1'
  spec.add_dependency 'jwt_auth'
  spec.add_dependency 'postmark-rails', '~> 0.22.1'
  spec.add_dependency 'rack-cors', '~> 2.0.1'
  spec.add_dependency 'rgeo-geojson', '~> 2.1'
  spec.add_dependency 'resource_api'
  spec.add_dependency 'rexml', '~> 3.2'
  spec.add_dependency 'rubyzip', '~> 2.3.2'
  spec.add_dependency 'user_defined_fields'
  spec.add_dependency 'triple_eye_effable'
  spec.add_dependency 'typesense', '~> 0.14'
  spec.add_dependency 'typhoeus', '~> 1.4'
end
