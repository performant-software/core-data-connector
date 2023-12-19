module CoreDataConnector
  module Public
    class TaxonomiesSerializer < LinkedOpenDataSerializer
      index_attributes(:id) { |taxonomy| "#{ENV['HOSTNAME']}/public/taxonomies/#{taxonomy.uuid}" }
      index_attributes(:title) { |taxonomy| taxonomy.name }
      index_attributes(:type) { 'Taxonomy' }
    end
  end
end