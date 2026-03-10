class AddAvatarUrlToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :core_data_connector_users, :avatar_url, :string
  end
end
