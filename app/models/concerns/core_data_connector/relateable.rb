module CoreDataConnector
  module Relateable
    extend ActiveSupport::Concern

    included do
      has_many :relationships, as: :primary_record, dependent: :destroy
    end
  end
end