module CoreDataConnector
  module Users
    class Invitations

      def send_invitation(recipient)
        user = recipient.is_a?(UserProject) ? recipient.user : recipient
        project = recipient.is_a?(UserProject) ? recipient.project : nil

        if is_clerk?
          send_clerk_invitation(user)
        else
          send_local_invitation(user, project)
        end
      end

      def is_clerk?
        ENV['VITE_AUTH_PROVIDER'] == 'clerk'
      end

      def send_clerk_invitation(user)
        clerk = Clerk::SDK.new(secret_key: ENV.fetch("CLERK_SECRET_KEY"))

        invite_user_request = Clerk::Models::Operations::CreateInvitationRequest.new(
          email_address: user.email,
          expires_in_days: 365,
          redirect_url: ENV['CLERK_REDIRECT_URL']
        )

        response = clerk.invitations.create(request: invite_user_request)

        Rails.logger.info("Clerk invitation created for #{user.email}")

        user.update!(sso_invitation_id: response.invitation.id)
      rescue StandardError => error
        Rails.logger.error("Clerk invitation failed for #{user.email}")
        Rails.logger.error("#{error.class}: #{error.message}")

        raise
      end

      def send_local_invitation(user, project)
        # Generate a new password
        password = Passwords.generate_user_password

        # Update the user's password
        user.update!(
          last_invited_at: Time.now.utc,
          password: password,
          password_confirmation: password,
          password_temporary: true,
          require_password_change: true
        )

        # Email the user the new password
        InvitationMailer.invite_user(user, password, project).deliver_later
      end
    end
  end
end