module CoreDataConnector
  class OrganizationPolicy < BasePolicy
    include OwnablePolicy

    attr_reader :current_user, :organization

    def initialize(current_user, organization)
      @current_user = current_user
      @organization = organization
    end

    # Allowed create/update attributes.
    def permitted_attributes
      attrs = [:description]
      attrs << ownable_attributes
      attrs << { organization_names_attributes: [:id, :name, :primary, :_destroy] }
      attrs
    end

    protected

    def project_item
      organization.project_item
    end

    # Include default ownable scope.
    class Scope < BaseScope
      include OwnableScope
    end
  end
end