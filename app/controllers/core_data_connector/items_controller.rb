module CoreDataConnector
  class ItemsController < ApplicationController
    include ImportableController
    include NameableController
    include OwnableController
    include UserDefinedFields::Queryable

    preloads source_titles: :name

    joins primary_name: :name

    def fcc_import
      item = Item.find(params[:item_id])
      project = Project.find(item.project_id)

      authorize project, :import_data?

      file_string = item.fetch_csv_zip

      # file_path = "#{Rails.root}/tmp/#{SecureRandom.urlsafe_base64}"

      tempfile = Tempfile.new
      tempfile.binmode
      tempfile.write(file_string)
      tempfile.rewind

      puts tempfile.inspect

      ok, errors = import(tempfile)

      if errors.nil? || errors.empty?
        render json: { }, status: :ok
      else
        render json: { errors: errors }, status: :unprocessable_entity
      end
    end
  end
end
