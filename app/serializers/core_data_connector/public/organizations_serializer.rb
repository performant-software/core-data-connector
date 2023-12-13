module CoreDataConnector
  module Public
    class OrganizationsSerializer < LinkedOpenDataSerializer
      index_attributes(:id) { |organization|  "#{ENV['HOSTNAME']}/public/organizations/#{organization.uuid}" }
      index_attributes(:title) { |organization| organization.name }
      index_attributes :description, user_defined: UserDefinedSerializer
    end
  end
end