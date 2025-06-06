module CoreDataConnector
  class UsersSerializer < BaseSerializer
    index_attributes :id, :name, :email, :role, :require_password_change
    show_attributes :id, :name, :email, :role, :require_password_change, user_projects: UserProjectsSerializer
  end
end