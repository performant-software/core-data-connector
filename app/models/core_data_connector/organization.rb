module CoreDataConnector
  class Organization < ApplicationRecord
    # Includes
    include Nameable
    include Ownable
    include Relateable
    include UserDefinedFields::Fieldable

    # Delegates
    delegate :name, to: :primary_name

    # User defined fields parent
    resolve_defineable -> (organization) { organization.project_model }
  end
end