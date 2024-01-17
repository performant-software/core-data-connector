module CoreDataConnector
  module Import
    class Relationships < Base
      def cleanup
        super

        execute <<-SQL.squish
          UPDATE core_data_connector_relationships
             SET z_relationship_id = NULL
        SQL
      end

      def load
        super

        execute <<-SQL.squish
          WITH

          insert_relationships AS (

          INSERT INTO core_data_connector_relationships (
            project_model_relationship_id,
            z_relationship_id,
            primary_record_id,
            primary_record_type,
            related_record_id,
            related_record_type,
            user_defined,
            created_at,
            updated_at
          )
          SELECT z_relationships.project_model_relationship_id,
                 z_relationships.id,
                 z_relationships.primary_record_id,
                 z_relationships.primary_record_type,
                 z_relationships.related_record_id,
                 z_relationships.related_record_type,
                 z_relationships.user_defined,
                 current_timestamp,
                 current_timestamp
            FROM #{table_name} z_relationships
           WHERE z_relationships.primary_record_id IS NOT NULL
             and z_relationships.related_record_id IS NOT NULL
          RETURNING id as relationship_id, z_relationship_id

          )

          UPDATE #{table_name} z_relationships
             SET relationship_id = insert_relationships.relationship_id
            FROM insert_relationships
           WHERE insert_relationships.z_relationship_id = z_relationships.id
        SQL
      end

      def transform
        super

        execute <<-SQL.squish
          WITH all_related_types AS (

          SELECT id, uuid, 'CoreDataConnector::Instance' AS type
            FROM core_data_connector_instances instances
           WHERE instances.z_instance_id IS NOT NULL
           UNION
          SELECT id, uuid, 'CoreDataConnector::Item' AS type
            FROM core_data_connector_items items
           WHERE items.z_item_id IS NOT NULL
           UNION
          SELECT id, uuid, 'CoreDataConnector::Organization' AS type
            FROM core_data_connector_organizations organizations
           WHERE organizations.z_organization_id IS NOT NULL
           UNION
          SELECT id, uuid, 'CoreDataConnector::Person' AS type
            FROM core_data_connector_people people
           WHERE people.z_person_id IS NOT NULL
           UNION
          SELECT id, uuid, 'CoreDataConnector::Place' AS type
            FROM core_data_connector_places places
           WHERE places.z_place_id IS NOT NULL
           UNION
          SELECT id, uuid, 'CoreDataConnector::Taxonomy' AS type
            FROM core_data_connector_taxonomies taxonomies
           WHERE taxonomies.z_taxonomy_id IS NOT NULL
           UNION
          SELECT id, uuid, 'CoreDataConnector::Work' AS type
            FROM core_data_connector_works works
           WHERE works.z_work_id IS NOT NULL

          )

          UPDATE #{table_name} z_relationships
             SET primary_record_id = primary_types.id,
                 related_record_id = related_types.id
            FROM all_related_types primary_types, all_related_types related_types
           WHERE primary_types.uuid = z_relationships.primary_record_uuid
             AND primary_types.type = z_relationships.primary_record_type
             AND related_types.uuid = z_relationships.related_record_uuid
             AND related_types.type = z_relationships.related_record_type
        SQL
      end

      protected

      def column_names
        [{
           name: 'project_model_relationship_id',
           type: 'INTEGER',
           copy: true
         }, {
           name: 'primary_record_uuid',
           type: 'UUID',
           copy: true
         }, {
           name: 'primary_record_type',
           type: 'VARCHAR',
           copy: true
         }, {
           name: 'related_record_uuid',
           type: 'UUID',
           copy: true
         }, {
           name: 'related_record_type',
           type: 'VARCHAR',
           copy: true
         }, {
           name: 'relationship_id',
           type: 'INTEGER'
         }, {
           name: 'primary_record_id',
           type: 'INTEGER'
         }, {
           name: 'related_record_id',
           type: 'INTEGER'
         }, {
           name: 'user_defined',
           type: 'JSONB'
         }]
      end

      def table_name_prefix
        'z_relationships'
      end
    end
  end
end
