class AddSsoInvitationIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :core_data_connector_users, :sso_invitation_id, :string
  end
end
