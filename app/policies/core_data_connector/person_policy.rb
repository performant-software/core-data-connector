module CoreDataConnector
  class PersonPolicy < BasePolicy
    include OwnablePolicy

    attr_reader :current_user, :person, :project_id

    def initialize(current_user, person)
      @current_user = current_user
      @person = person
      @project_id = person&.project_id
    end

    # Allowed create/update attributes.
    def permitted_attributes
      attrs = [:biography, user_defined: {}]
      attrs << ownable_attributes
      attrs << { person_names_attributes: [:id, :first_name, :middle_name, :last_name, :primary, :_destroy] }
      attrs
    end

    # Include default ownable scope.
    class Scope < BaseScope
      include OwnableScope
    end
  end
end