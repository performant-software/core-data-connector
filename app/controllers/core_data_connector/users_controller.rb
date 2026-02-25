module CoreDataConnector
  class UsersController < ApplicationController
    # Search attributes
    search_attributes :name, :email

    # Preloads
    preloads user_projects: :project, only: :show

    def invite
      user = User.find(params[:id])
      authorize user, :update?

      begin
        service = Users::Invitations.new
        service.send_invitation user
      rescue StandardError => error
        errors = [error]

        # Log the error
        log_error(error)
      end

      if errors.nil? || errors.empty?
        render json: { }, status: :ok
      else
        render json: { errors: errors }, status: :bad_request
      end
    end

    protected

    def after_update(user)
      super

      # If the user is resetting their password, set the "require_password_change" prop to false
      if current_user.id == user.id && user.saved_change_to_password_digest? && user.require_password_change?
        user.update_column(:require_password_change, false)
      end
    end
  end
end