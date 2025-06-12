module CoreDataConnector
  module Users
    class Passwords

      SSO_PASSWORD_LENGTH = 50
      USER_PASSWORD_LENGTH = 6

      # Password format
      PASSWORD_FORMAT = /\A
        (?=.{8,})          # Must contain 8 or more characters
        (?=.*\d)           # Must contain a digit
        (?=.*[a-z])        # Must contain a lower case character
        (?=.*[A-Z])        # Must contain an upper case character
        (?=.*[[:^alnum:]]) # Must contain a symbol
      /x

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