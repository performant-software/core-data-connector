module CoreDataConnector
  class UsersSerializer < BaseSerializer
    index_attributes :id, :name, :email, :role, :require_password_change, :last_sign_in_at
    show_attributes :id, :name, :email, :role, :require_password_change, :last_sign_in_at, user_projects: UserProjectsSerializer
  end
end