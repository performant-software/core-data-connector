module CoreDataConnector
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    desc "CoreDataConnector migrations"
    def copy_initializer
      rake 'core_data_connector:install:migrations'
      rake "fuzzy_dates:install:migrations"
    end
  end
end