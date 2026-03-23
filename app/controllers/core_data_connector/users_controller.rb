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

    def me
      authenticate_clerk_request

      return unless @current_user

      clerk_user = get_clerk_data(@current_user.sso_id)

      update_user_from_sso(@current_user, clerk_user)

      render json: @current_user, status: :ok
    end

    def build_name(first, last)
      if first.present? && last.present?
        name = "#{first} #{last}"
      elsif first.present?
        name = first
      elsif last.present?
        name = last
      end

      name
    end

    def update_user_from_sso(local_user, sso_user)
      # default to guest, which means users can't create projects
      role = 'guest'

      if sso_user.private_metadata['is_performant'] == true
        # *we* should be CD admins (and no one else!)
        role = 'admin'
      else
        # get user's role from their main organization membership role
        org_memberships = clerk_client.users.get_organization_memberships(user_id: sso_user.id)
        main_org = org_memberships.organization_memberships.data.first

        org_role = main_org.role

        # org admins are Performant Studio customers who should be able to create projects,
        # which means they get the member system role in Core Data
        role = 'member' if org_role == 'org:admin'
      end

      local_user.update(
        sso_id: sso_user.id,
        name: build_name(sso_user.first_name, sso_user.last_name),
        avatar_url: sso_user.profile_image_url,
        role: role
      )
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