class AddIndexToUsersOnSsoId < ActiveRecord::Migration[8.0]
  def change
    add_index :core_data_connector_users, :sso_id, unique: true
  end
end
