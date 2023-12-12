class CreateCoreDataConnectorTaxonomies < ActiveRecord::Migration[7.0]
  def change
    create_table :core_data_connector_taxonomies do |t|
      t.references :project_model
      t.string :name

      t.timestamps
    end
  end
end
