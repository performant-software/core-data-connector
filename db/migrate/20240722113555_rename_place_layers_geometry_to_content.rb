class RenamePlaceLayersGeometryToContent < ActiveRecord::Migration[7.0]
  def change
    rename_column :core_data_connector_place_layers, :geometry, :content
  end
end
