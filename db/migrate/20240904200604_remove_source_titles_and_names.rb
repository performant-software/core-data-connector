class RemoveSourceTitlesAndNames < ActiveRecord::Migration[7.0]
  def change
    drop_table :core_data_connector_source_titles
    drop_table :core_data_connector_names
  end
end
