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
    before_save :set_require_password_change
    before_validation :set_sso_password, on: :create

    # Validations
    validate :validate_sso_password
    validates :email, uniqueness: true
    validates :role, inclusion:  { in: ALLOWED_ROLES, message: I18n.t('errors.users.roles') }

    def admin?
      role === ROLE_ADMIN
    end

    def guest?
      role === ROLE_GUEST
    end

    def member?
      role === ROLE_MEMBER
    end

    private

    # Set the require_password_change attribute to "false" if the user has changed their password and this
    # is not a new record.
    def set_require_password_change
      if password_digest_changed? && !new_record?
        self.require_password_change = false
      end
    end

    # Add a long, random password for accounts created via SSO
    def set_sso_password
      if SSO_DOMAINS.any? { |d| self.email.end_with?(d) }
        random_password = SecureRandom.base64(50)
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