class CreateCoreDataConnectorItems < ActiveRecord::Migration[7.0]
  def change
    create_table :core_data_connector_items do |t|
      t.references :project_model
      t.uuid :uuid, default: 'gen_random_uuid()', null: false

      t.timestamps
    end
  end
end
