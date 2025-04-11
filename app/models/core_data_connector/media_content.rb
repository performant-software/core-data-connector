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
      udf_uuids = self.user_defined.keys

      udfs = UserDefinedFields::UserDefinedField.where(uuid: udf_uuids)

      values = []

      udfs.each do |udf|
        values.push({
          label: udf[:column_name],
          value: self.user_defined[udf[:uuid]]
        })
      end

      values.to_json
    end

    # User defined fields parent
    resolve_defineable -> (media_content) { media_content.project_model }
  end
end