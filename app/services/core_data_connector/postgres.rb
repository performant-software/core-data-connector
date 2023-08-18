module CoreDataConnector
  # Name for the default schema variable.
  DEFAULT_SCHEMA = 'public'

  # Name for the sequence suffix
  SEQUENCE_SUFFIX = '_id_seq'

  # Name for the ID sequence view suffix
  SEQUENCE_VIEW_SUFFIX = '_id_seq_view'

  # Name for the foreign data wrapper server
  SERVER_NAME = 'core_data_fdw'

  # Delimiter constant
  TABLE_DELIMITER = ','

  class Postgres
    def analyze_tables
      table_names.each do |table_name|
        execute <<-SQL.squish
          ANALYZE #{table_name};
        SQL
      end
    end

    def create_foreign_data_wrapper(
      local_schema: DEFAULT_SCHEMA,
      local_username:,
      remote_host:,
      remote_port:,
      remote_schema: DEFAULT_SCHEMA,
      remote_database:,
      remote_username:,
      remote_password:
    )
      # Create the extension
      execute <<-SQL.squish
        CREATE EXTENSION IF NOT EXISTS postgres_fdw;
      SQL

      # Drop existing server
      execute <<-SQL.squish
        DROP SERVER IF EXISTS #{SERVER_NAME} CASCADE;
      SQL

      # Create the server
      execute <<-SQL.squish
         CREATE SERVER #{SERVER_NAME}
        FOREIGN DATA WRAPPER postgres_fdw 
        OPTIONS (host '#{remote_host}', port '#{remote_port}', dbname '#{remote_database}', use_remote_estimate 'on');
      SQL

      # Create user mapping
      execute <<-SQL.squish
        CREATE USER MAPPING FOR #{local_username} SERVER #{SERVER_NAME} OPTIONS (user '#{remote_username}', password '#{remote_password}');
      SQL

      # Grant access to foreign data wrapper
      execute <<-SQL.squish
        GRANT USAGE ON FOREIGN SERVER #{SERVER_NAME} TO #{local_username};
      SQL

      # Import the schema
      tables = []

      table_names.each do |table_name|
        tables << table_name
        tables << sequence_view_name_for_table(table_name)
      end

      execute <<-SQL.squish
         IMPORT 
        FOREIGN SCHEMA #{remote_schema} 
          LIMIT TO (#{tables.join(TABLE_DELIMITER)}) 
           FROM SERVER #{SERVER_NAME} 
           INTO #{local_schema};
      SQL

      table_names.each do |table_name|
        # Set the fetch size for each table
        execute <<-SQL.squish
          ALTER FOREIGN TABLE #{table_name} OPTIONS ( fetch_size '10000' );
        SQL

        # Create function to return next ID value
        function_name = function_name_for_table(table_name)

        execute <<-SQL.squish
          CREATE FUNCTION #{function_name}() RETURNS bigint AS
            'SELECT ID FROM #{sequence_view_name_for_table(table_name)}'
          LANGUAGE SQL;
        SQL

        # Create trigger function to set ID value on insert
        trigger_name = trigger_name_for_table(table_name)

        execute <<-SQL.squish
          CREATE OR REPLACE FUNCTION #{trigger_name}()
          RETURNS TRIGGER
          LANGUAGE PLPGSQL AS 
          $$
             BEGIN
                IF NEW.id IS NULL THEN
                  NEW.id = #{function_name}();
                END IF;
            RETURN NEW;
               END;
          $$
          ;
        SQL

        # Set trigger on table
        execute <<-SQL.squish
           CREATE TRIGGER #{trigger_name}
           BEFORE INSERT ON #{table_name} FOR EACH ROW
          EXECUTE PROCEDURE #{trigger_name}();
        SQL
      end
    end

    def create_foreign_user
      service = User.new

      username = service.create_username
      password = service.create_password

      execute <<-SQL.squish
        CREATE USER #{username} WITH PASSWORD '#{password}';
      SQL

      table_names.each do |table_name|
        # Grant all permissions to core data tables
        execute <<-SQL.squish
          GRANT ALL ON #{table_name} to #{username};
        SQL

        # Grant all permissions to core data sequence views
        execute <<-SQL.squish
          GRANT ALL ON #{sequence_view_name_for_table(table_name)} TO #{username}
        SQL
      end

      { username: username, password: password }
    end

    def create_sequence_views
      table_names.each do |table_name|
        sequence_name = sequence_name_for_table(table_name)
        view_name = sequence_view_name_for_table(table_name)

        # Drop the view if it exists
        execute <<-SQL.squish
          DROP VIEW IF EXISTS #{view_name} CASCADE
        SQL

        # Create a new view
        execute <<-SQL.squish
          CREATE VIEW #{view_name} AS
          SELECT NEXTVAL('#{sequence_name}'::regclass) as id
        SQL
      end
    end

    def delete_foreign_data_wrapper
      # Drop existing server
      execute <<-SQL.squish
        DROP SERVER IF EXISTS #{SERVER_NAME} CASCADE;
      SQL

      table_names.each do |table_name|
        # Remove trigger from table
        trigger_name = trigger_name_for_table(table_name)

        execute <<-SQL.squish
          DROP TRIGGER IF EXISTS #{trigger_name} ON #{table_name} CASCADE
        SQL

        # Remove trigger function to set ID value on insert
        execute <<-SQL.squish
          DROP FUNCTION IF EXISTS #{trigger_name}
        SQL

        # Remove function to return next ID value
        function_name = function_name_for_table(table_name)

        execute <<-SQL.squish
          DROP FUNCTION IF EXISTS #{function_name}
        SQL
      end
    end

    def delete_foreign_user(username)
      # Drop the user's permissions and owned objects. This statement will fail if the user doesn't exist,
      # but I can't find a way to conditionally drop.
      execute <<-SQL.squish
        DROP OWNED BY #{username};
      SQL

      # Drop the user if they exist.
      execute <<-SQL.squish
        DROP USER IF EXISTS #{username};
      SQL
    end

    private

    def execute(sql)
      begin
        ActiveRecord::Base.connection.execute sql
      rescue StandardError => e
        puts e.inspect
      end
    end

    def function_name_for_table(table_name)
      "#{table_name}_next"
    end

    def table_names
      # Lazy eager load the application to load all of the models
      Rails.application.eager_load!

      # Get all of the table names for each of the models
      ApplicationRecord.descendants.map(&:table_name)
    end

    def sequence_name_for_table(table_name)
      "#{table_name}#{SEQUENCE_SUFFIX}"
    end

    def sequence_view_name_for_table(table_name)
      "#{table_name}#{SEQUENCE_VIEW_SUFFIX}"
    end

    def trigger_name_for_table(table_name)
      "set_id_on_#{table_name}_insert"
    end
  end
end
