module CoreDataConnector
  class WebIdentifiersSerializer < BaseSerializer
    index_attributes :id, :identifier, web_authority: WebAuthoritiesSerializer
    show_attributes :id, :identifier, web_authority: WebAuthoritiesSerializer
  end
end