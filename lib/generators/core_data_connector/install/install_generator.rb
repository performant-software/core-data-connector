module CoreDataConnector
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    desc "CoreDataConnector migrations"
    def copy_initializer
      rake 'core_data_connector:install:migrations'
      rake "triple_eye_effable:install:migrations"
      rake "user_defined_fields:install:migrations"
    end
  end
end