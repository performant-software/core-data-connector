class AddUuidToProjectModelRelationships < ActiveRecord::Migration[7.0]
  def change
    add_column :core_data_connector_project_model_relationships, :uuid, :uuid, default: 'gen_random_uuid()', null: false
  end
end
