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
  spec.add_dependency 'resource_api'
end
