class CreateCoreDataConnectorPlaces < ActiveRecord::Migration[7.0]
  def change
    create_table :core_data_connector_places do |t|
      t.string :uid

      t.timestamps
    end
  end
end
