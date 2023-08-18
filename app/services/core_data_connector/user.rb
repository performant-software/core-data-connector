require 'active_support'
require 'faker'

module CoreDataConnector
  # Name for the adjective positivity rate
  ADJECTIVE_POSITIVE_RATE = 70

  # Name for the default password length
  DEFAULT_PASSWORD_LENGTH = 8

  # Username delimiter
  DELIMITER = '_'

  class User
    def create_username
      [create_adjective, create_noun].join(DELIMITER).parameterize(separator: DELIMITER)
    end

    def create_password(length = DEFAULT_PASSWORD_LENGTH)
      SecureRandom.hex(length)
    end

    private

    def create_adjective
      if Random.new.rand(100) > ADJECTIVE_POSITIVE_RATE
        Faker::Adjective.negative
      else
        Faker::Adjective.positive
      end
    end

    def create_noun
      Faker::Creature::Animal.name
    end
  end
end
