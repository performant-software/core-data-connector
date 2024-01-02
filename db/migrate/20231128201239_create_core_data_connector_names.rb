class CreateCoreDataConnectorNames < ActiveRecord::Migration[7.0]
  def change
    create_table :core_data_connector_names do |t|
      t.string :name

      t.timestamps
    end
  end
end
