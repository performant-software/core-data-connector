class CreateCoreDataConnectorPlaceNames < ActiveRecord::Migration[7.0]
  def change
    create_table :core_data_connector_place_names do |t|
      t.references :place, null: false, index: true
      t.string :name
      t.boolean :primary

      t.timestamps
    end
  end
end
