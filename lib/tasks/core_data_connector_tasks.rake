namespace :core_data_connector do

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
