module CoreDataConnector
  module Public
    class MediaContentsSerializer < LinkedOpenDataSerializer
      index_attributes(:id) { |media_content|  "#{ENV['HOSTNAME']}/public/media_contents/#{media_content.uuid}" }
      index_attributes(:record_id) { |media_content| media_content.id }
      index_attributes(:title) { |media_content| media_content.name }
      index_attributes(:type) { 'MediaContent' }
      index_attributes :content_url, :content_download_url, :content_iiif_url, :content_preview_url,
                       :content_thumbnail_url, :manifest_url, user_defined: UserDefinedSerializer
    end
  end
end