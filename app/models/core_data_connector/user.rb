module CoreDataConnector
  class User < ApplicationRecord
    # Relationships
    has_many :user_projects, dependent: :destroy

    # JWT
    has_secure_password

    # Validations
    validates :email, uniqueness: true

    validate :validate_reset_password

    def validate_reset_password
      if password_digest_changed? && self.sso_id
        errors.add(:password, I18n.t('errors.users.password.sso'))
      end
    end
  end
end