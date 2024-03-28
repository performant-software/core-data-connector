require 'typhoeus'

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

    CODE_NO_RESPONSE = 0

    # Nameable table
    name_table :source_titles, polymorphic: true

    # Generate the full URL for the item's CSV files in FairCopy.cloud
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

    def fetch_csv_zip
      url = self.faircopy_cloud_url

      if !url
        return nil
      end

      request = Typhoeus::Request.new(url)

      response = request.run

      if response.success?
        return response.body
      elsif response.timed_out?
        { error: I18n.t('errors.http.timeout') }
      elsif response.code == CODE_NO_RESPONSE
        { error: I18n.t('errors.http.no_response') }
      else
        { error: I18n.t('errors.http.general') }
      end
    end
  end
end
