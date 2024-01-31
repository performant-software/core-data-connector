module CoreDataConnector
  module Public
    module UserDefineableSerializer
      extend ActiveSupport::Concern

      included do
        index_attributes user_defined: UserDefinedSerializer
        show_attributes user_defined: UserDefinedSerializer
      end
    end
  end
end