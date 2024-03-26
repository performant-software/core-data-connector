module CoreDataConnector
  class Item < ApplicationRecord
    # Includes
    include Identifiable
    include Manifestable
    include Nameable
    include Ownable
    include Relateable
    include UserDefinedFields::Fieldable
    include Search::Item

    # Nameable table
    name_table :source_titles, polymorphic: true

    def faircopy_cloud_url
      if !self[:faircopy_cloud_id]
        return nil
      end

      project = self.project_model.project

      if !project[:faircopy_cloud_url]
        return nil
      end

      "#{project[:faircopy_cloud_url]}/documents/#{self[:faircopy_cloud_id]}/csv"
    end
  end
end
