module CoreDataConnector
  module Public
    module UnauthenticateableController
      extend ActiveSupport::Concern

      included do
        # No user authentication
        skip_before_action :authenticate_request

        # No Pundit authorization
        before_action :bypass_authorization
      end

    end
  end
end