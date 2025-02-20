class AddIndexToRelationships < ActiveRecord::Migration[7.0]
  def change
    add_index :core_data_connector_relationships, [:primary_record_id, :related_record_id, :related_record_type, :primary_record_type], name: 'index_relationships_record_ids_and_types'
  end
end
