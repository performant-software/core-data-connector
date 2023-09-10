class AddAdminToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :core_data_connector_users, :admin, :boolean, default: false
  end
end
