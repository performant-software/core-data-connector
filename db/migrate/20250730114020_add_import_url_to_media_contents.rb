class AddImportUrlToMediaContents < ActiveRecord::Migration[8.0]
  def change
    add_column :core_data_connector_media_contents, :import_url, :string
    add_column :core_data_connector_media_contents, :import_url_processed, :boolean, null: false, default: false
  end
end
