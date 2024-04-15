namespace :core_data_connector do

  namespace :data do
    desc 'Calls the before_create method for each web_identifier record'
    task :reset_web_identifiers => :environment do
      CoreDataConnector::WebIdentifier.all.find_each do |web_identifier|
        service = CoreDataConnector::Authority::Base.create_service(web_identifier.web_authority)
        service.before_create(web_identifier)
        web_identifier.save
      end
    end
  end

  namespace :db do
    desc 'Creates a new database user with access to the core data tables. This tasks should be run on the Core Data Cloud.'
    task :create_db_user => :environment do
      postgres = CoreDataConnector::Postgres.new
      result = postgres.create_foreign_user

      puts "Created #{result[:username]} with password #{result[:password]}."
    end

    desc 'Creates the foreign data wrapper. This task should be run on the local application.'
    task :create_foreign_data_wrapper => :environment do
      postgres = CoreDataConnector::Postgres.new
      postgres.create_foreign_data_wrapper(
        local_username: ENV['DATABASE_USERNAME'],
        remote_host: ENV['CORE_DATA_CLOUD_HOST'],
        remote_port: ENV['CORE_DATA_CLOUD_PORT'],
        remote_database: ENV['CORE_DATA_CLOUD_DATABASE'],
        remote_username: ENV['CORE_DATA_CLOUD_USERNAME'],
        remote_password: ENV['CORE_DATA_CLOUD_PASSWORD']
      )
    end
  end

  namespace :iiif do
    desc 'Resets IIIF manifests for all records.'
    task :reset_manifests => :environment do
      service = CoreDataConnector::Iiif::Manifest.new
      service.reset_manifests
    end
  end
end
