class CreateCoreDataConnectorProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :core_data_connector_projects do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
