class AddRequirePasswordChangeToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :core_data_connector_users, :require_password_change, :boolean, default: false, null: false
  end
end
