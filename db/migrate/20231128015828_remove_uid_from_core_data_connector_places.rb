class RemoveUidFromCoreDataConnectorPlaces < ActiveRecord::Migration[7.0]
  def change
    remove_column :core_data_connector_places, :uid
  end
end
