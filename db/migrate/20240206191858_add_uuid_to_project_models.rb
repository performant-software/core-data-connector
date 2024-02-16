class AddUuidToProjectModels < ActiveRecord::Migration[7.0]
  def change
    add_column :core_data_connector_project_models, :uuid, :uuid, default: 'gen_random_uuid()', null: false
  end
end
