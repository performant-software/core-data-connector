module CoreDataConnector
  class OrganizationPolicy < BasePolicy
    include OwnablePolicy

    attr_reader :current_user, :organization, :project_id

    def initialize(current_user, organization)
      @current_user = current_user
      @organization = organization
      @project_id = organization&.project_id
    end

    # Allowed create/update attributes.
    def permitted_attributes
      attrs = [:description]
      attrs << ownable_attributes
      attrs << { organization_names_attributes: [:id, :name, :primary, :_destroy] }
      attrs
    end

    # Include default ownable scope.
    class Scope < BaseScope
      include OwnableScope
    end
  end
end