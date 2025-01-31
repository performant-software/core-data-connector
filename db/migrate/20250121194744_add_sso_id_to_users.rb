class AddSsoIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :core_data_connector_users, :sso_id, :uuid
  end
end
