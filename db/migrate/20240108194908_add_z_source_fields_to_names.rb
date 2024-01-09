class AddZSourceFieldsToNames < ActiveRecord::Migration[7.0]
  def change
    add_column :core_data_connector_names, :z_source_id, :integer
    add_column :core_data_connector_names, :z_source_type, :string
  end
end
