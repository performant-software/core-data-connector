class AddZWorkIdToCoreDataConnectorWorks < ActiveRecord::Migration[7.0]
  def change
    add_column :core_data_connector_works, :z_work_id, :integer
  end
end
