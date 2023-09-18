class AddSlugToProjectModelRelationships < ActiveRecord::Migration[7.0]
  def change
    add_column :core_data_connector_project_model_relationships, :slug, :string
  end
end
