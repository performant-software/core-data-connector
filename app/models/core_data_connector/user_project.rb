module CoreDataConnector
  class UserProject < ApplicationRecord
    # Constants
    ROLE_OWNER = 'owner'
    ROLE_EDITOR = 'editor'
    ALLOWED_ROLES = [
      ROLE_OWNER,
      ROLE_EDITOR
    ]

    # Relationships
    belongs_to :user
    belongs_to :project

    # Transient attributes
    attr_accessor :name, :email, :password, :password_confirmation

    # Validations
    validates :role, inclusion:  { in: ALLOWED_ROLES, message: I18n.t('errors.user_project.roles') }
    validates :user_id, uniqueness: { scope: :project_id, message: I18n.t('errors.user_project.unique') }

    # Callbacks
    before_update :reset_password
    before_validation :find_or_create_user, on: :create

    private

    # Create the user record at the same time if the correct attributes are provided and no user_id is set. We'll
    # only update the name and password if the user is a new record.
    def find_or_create_user
      return unless user_id.nil? && name.present? && email.present? && password.present? && password_confirmation.present?

      user = User.find_or_create_by(email: email) do |user|
        next unless user.new_record?

        user.assign_attributes(
          name: name,
          password: password,
          password_confirmation: password_confirmation
        )
      end

      self.user_id = user.id
    end

    # Reset the user's password if the password and password confirmation attributes are provided
    def reset_password
      return unless user_id.present? && password.present? && password_confirmation.present?

      user.update(
        password: password,
        password_confirmation: password_confirmation
      )
    end
  end
end