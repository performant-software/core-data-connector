module CoreDataConnector
  class Organization < ApplicationRecord
    # Includes
    include Identifiable
    include Manifestable
    include Nameable
    include Ownable
    include Relateable
    include Search::Organization
    include UserDefinedFields::Fieldable

    # Delegates
    delegate :name, to: :primary_name

    name_table :organization_names

    # User defined fields parent
    resolve_defineable -> (organization) { organization.project_model }
  end
end