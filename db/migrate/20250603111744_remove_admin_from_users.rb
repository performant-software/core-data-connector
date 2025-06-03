class RemoveAdminFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :core_data_connector_users, :admin
  end
end
