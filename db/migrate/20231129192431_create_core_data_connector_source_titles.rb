class CreateCoreDataConnectorSourceTitles < ActiveRecord::Migration[7.0]
  def change
    create_table :core_data_connector_source_titles do |t|
      t.references :nameable, polymorphic: true
      t.references :name
      t.boolean :primary

      t.timestamps
    end
  end
end
