module CoreDataConnector
  module Users
    class Passwords

      SSO_PASSWORD_LENGTH = 50
      USER_PASSWORD_LENGTH = 6

      def self.generate_sso_password
        generate_password SSO_PASSWORD_LENGTH
      end

      def self.generate_user_password
        generate_password USER_PASSWORD_LENGTH
      end

      private

      def self.generate_password(length)
        SecureRandom.base64(length)
      end

    end
  end
end