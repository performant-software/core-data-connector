module CoreDataConnector
  class User < ApplicationRecord
    # Domains that have SSO enabled
    SSO_DOMAINS = ENV['REACT_APP_SSO_DOMAINS'] ? ENV['REACT_APP_SSO_DOMAINS'].split(',') : []

    # Relationships
    has_many :user_projects, dependent: :destroy

    # JWT
    has_secure_password

    before_validation :set_sso_password, on: :create

    # Validations
    validates :email, uniqueness: true
    validate :validate_sso_password

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