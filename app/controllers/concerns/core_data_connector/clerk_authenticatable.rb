module CoreDataConnector
  module ClerkAuthenticatable
    private

    def authenticate_clerk_request
      token = clerk_bearer_token
      return render_unauthorized unless token.present?

      clerk_session = clerk_client.verify_token(token)
      clerk_id = clerk_session["sub"]

      @clerk_user = clerk_client.users.get(user_id: clerk_id).user
      @current_user = find_local_user_from_clerk(clerk_id, @clerk_user)

      return render_not_found unless @current_user

      @current_user
    rescue StandardError => error
      log_error(error)
      render_unauthorized
    end

    def clerk_bearer_token
      request.headers["Authorization"]&.split(" ")&.last
    end

    def clerk_client
      @clerk_client ||= Clerk::SDK.new(secret_key: ENV.fetch("CLERK_SECRET_KEY"))
    end

    def find_local_user_from_clerk(clerk_id, clerk_user)
      User.find_by(sso_id: clerk_id) || User.find_by(email: clerk_primary_email(clerk_user))
    end

    def clerk_primary_email(clerk_user)
      primary_id = clerk_user.primary_email_address_id

      clerk_user.email_addresses.find { |address| address.id == primary_id }&.email_address
    end

    def render_unauthorized
      render json: { error: I18n.t("errors.users.unauthorized") }, status: :unauthorized
    end

    def render_not_found
      render json: { error: I18n.t("errors.users.not_found") }, status: :unauthorized
    end
  end
end