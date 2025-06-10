module CoreDataConnector
  class User < ApplicationRecord
    # Roles
    ROLE_ADMIN = 'admin'
    ROLE_MEMBER = 'member'
    ROLE_GUEST = 'guest'

    ALLOWED_ROLES = [
      ROLE_ADMIN,
      ROLE_MEMBER,
      ROLE_GUEST
    ]

    # Domains that have SSO enabled
    SSO_DOMAINS = ENV['REACT_APP_SSO_DOMAINS'] ? ENV['REACT_APP_SSO_DOMAINS'].split(',') : []

    # Relationships
    has_many :user_projects, dependent: :destroy

    # JWT
    has_secure_password

    # Actions
    before_validation :set_sso_password, on: :create

    # Validations
    validate :validate_sso_password
    validates :email, uniqueness: true
    validates :role, inclusion:  { in: ALLOWED_ROLES, message: I18n.t('errors.users.roles') }

    def admin?
      role === ROLE_ADMIN
    end

    def authenticate(password)
      success = super

      # Update the user's last sign in at timestamp
      update(last_sign_in_at: Time.now.utc) if success

      success
    end

    def guest?
      role === ROLE_GUEST
    end

    def member?
      role === ROLE_MEMBER
    end

    private

    # Add a long, random password for accounts created via SSO
    def set_sso_password
      if SSO_DOMAINS.any? { |d| self.email.end_with?(d) }
        random_password = Users::Passwords.generate_sso_password
        self.password = random_password
        self.password_confirmation = random_password
      end
    end

    # Make sure you can't reset the password of an SSO user
    def validate_sso_password
      if password_digest_changed? && self.sso_id
        errors.add(:password, I18n.t('errors.users.password.sso'))
      end
    end
  end
end