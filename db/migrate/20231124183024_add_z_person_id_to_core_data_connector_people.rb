class AddZPersonIdToCoreDataConnectorPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :core_data_connector_people, :z_person_id, :integer
  end
end
