module CoreDataConnector
  class UsersSerializer < BaseSerializer
    index_attributes :id, :name, :email, :role, :require_password_change, :last_sign_in_at, :last_invited_at
    index_attributes(:sso) { |user| user.sso_id.present? }

    show_attributes :id, :name, :email, :role, :require_password_change, :last_sign_in_at, :last_invited_at,
                    user_projects: UserProjectsSerializer

    show_attributes(:sso) { |user| user.sso_id.present? }
  end
end