module CoreDataConnector
  class UsersSerializer < BaseSerializer
    index_attributes :id, :name, :email, :role
    show_attributes :id, :name, :email, :role, user_projects: UserProjectsSerializer
  end
end