class AddAllowIdentifiersToProjectModels < ActiveRecord::Migration[7.0]
  def change
    add_column :core_data_connector_project_models, :allow_identifiers, :boolean, default: false
  end
end
