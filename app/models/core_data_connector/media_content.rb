module CoreDataConnector
  class MediaContent < ApplicationRecord
    # Includes
    include Identifiable
    include Manifestable
    include Mergeable
    include Ownable
    include Relateable
    include Search::MediaContent
    include TripleEyeEffable::Resourceable
    include UserDefinedFields::Fieldable

    def metadata
      if !self.user_defined || self.user_defined.keys.count == 0
        return '[]'
      end

      fields = UserDefinedFields::UserDefinedField.where(uuid: self.user_defined.keys).map do |udf|
        {
          label: udf[:column_name],
          value: self.user_defined[udf[:uuid]]
        }
      end

      fields.to_json
    end

    # User defined fields parent
    resolve_defineable -> (media_content) { media_content.project_model }
  end
end