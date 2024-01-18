class AddZTaxonomyIdToTaxonomies < ActiveRecord::Migration[7.0]
  def change
    add_column :core_data_connector_taxonomies, :z_taxonomy_id, :integer
  end
end
