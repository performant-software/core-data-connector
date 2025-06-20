module CoreDataConnector
  module Users
    class Invitations

      def send_invitation(user_project)
        user = user_project.user
        project = user_project.project

        # Generate a new password
        password = Passwords.generate_user_password

        # Update the user's password
        user.update(
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