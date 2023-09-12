module CoreDataConnector
  class PersonPolicy < BasePolicy
    include OwnablePolicy

    attr_reader :current_user, :person

    def initialize(current_user, person)
      @current_user = current_user
      @person = person
    end

    # Allowed create/update attributes.
    def permitted_attributes
      attrs = []
      attrs << ownable_attributes
      attrs << { person_names_attributes: [:id, :first_name, :middle_name, :last_name, :primary, :_destroy] }
      attrs
    end

    protected

    def project_item
      person.project_item
    end

    # Include default ownable scope.
    class Scope < BaseScope
      include OwnableScope
    end
  end
end