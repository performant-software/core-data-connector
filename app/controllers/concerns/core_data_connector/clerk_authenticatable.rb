module CoreDataConnector
  module ClerkAuthenticatable
    private

    def authenticate_clerk_request
      token = request.cookies["__session"]
      return render_unauthorized unless token.present?

      clerk_session = clerk_client.verify_token(token)
      clerk_id = clerk_session["sub"]

      @clerk_user = clerk_client.users.get(user_id: clerk_id).user
      @current_user = User.find_by(sso_id: clerk_id)

      return render_not_found unless @current_user

      @current_user
    rescue StandardError => error
      log_error(error)
      render_unauthorized
    end

    def clerk_client
      @clerk_client ||= Clerk::SDK.new(secret_key: ENV.fetch("CLERK_SECRET_KEY"))
    end

    def render_unauthorized
      render json: { error: I18n.t("errors.users.unauthorized") }, status: :unauthorized
    end

    def render_not_found
      render json: { error: I18n.t("errors.users.not_found") }, status: :unauthorized
    end
  end
end