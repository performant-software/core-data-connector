module CoreDataConnector
  module Reconcile
    class ProjectsSerializer < BaseSerializer

      index_attributes :id, :name, :description, :score, :match, :type

      def render_multiple(searches)
        searches.keys.inject({}) do |hash, key|
          hash[key] = {
            result: render_index(searches[key])
          }

          hash
        end
      end

      def render_manifest
        {
          defaultTypes: [{
            id: CoreDataConnector::Event.to_s,
            name: CoreDataConnector::Event.name.demodulize,
          }, {
            id: CoreDataConnector::Instance.to_s,
            name: CoreDataConnector::Instance.name.demodulize,
          }, {
            id: CoreDataConnector::Item.to_s,
            name: CoreDataConnector::Item.name.demodulize,
          }, {
            id: CoreDataConnector::Organization.to_s,
            name: CoreDataConnector::Organization.name.demodulize,
          }, {
            id: CoreDataConnector::Person.to_s,
            name: CoreDataConnector::Person.name.demodulize,
          }, {
            id: CoreDataConnector::Place.to_s,
            name: CoreDataConnector::Place.name.demodulize,
          }, {
            id: CoreDataConnector::Taxonomy.to_s,
            name: CoreDataConnector::Taxonomy.name.demodulize,
          }, {
            id: CoreDataConnector::Work.to_s,
            name: CoreDataConnector::Work.name.demodulize,
          }],
          identifierSpace: "#{ENV['HOSTNAME']}/core_data/public/v1",
          name: I18n.t('services.reconcile.name'),
          schemaSpace: "#{ENV['HOSTNAME']}/core_data/reconcile",
          versions: %w(0.1 0.2)
        }
      end

    end
  end
end