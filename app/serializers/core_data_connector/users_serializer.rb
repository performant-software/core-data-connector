module CoreDataConnector
  class UsersSerializer < BaseSerializer
    index_attributes :id, :name, :email, :admin, :sso_id
    show_attributes :id, :name, :email, :admin, :sso_id, user_projects: UserProjectsSerializer
  end
end