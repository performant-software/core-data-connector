class CreateCoreDataConnectorPeople < ActiveRecord::Migration[7.0]
  def change
    create_table :core_data_connector_people do |t|
      t.text :biography

      t.timestamps
    end
  end
end
