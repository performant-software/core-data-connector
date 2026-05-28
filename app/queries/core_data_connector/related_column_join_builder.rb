module CoreDataConnector
  class RelatedColumnJoinBuilder
    def initialize(source_model:, project_model_relationship_id:, field:)
      @source_model = source_model
      @pmr_id       = project_model_relationship_id
      @field        = field
    end

    def joins
      [relationship_join, target_join]
    end

    def select_fragment
      # todo: handle name joins
      if user_defined_field?
        key = @field.sub('udf.', '')
        "(#{target_alias}.user_defined ->> #{quote(key)}) AS #{column_alias}"
      else
        validate_column!
        "#{target_alias}.#{@field} AS #{column_alias}"
      end
    end

    def column_alias
      @column_alias ||= "rel_#{@pmr_id}_#{@field.gsub(/\W/, '_')}"
    end

    def requires_aggregation?
      direction == :forward ? pmr.multiple : pmr.inverse_multiple
    end

    private

    def pmr
      @pmr ||= ProjectModelRelationship
                 .includes(:primary_model, :related_model)
                 .find(@pmr_id)
    end

    def direction
      @direction ||=
        if pmr.primary_model.model_class == @source_model.name
          :forward
        elsif pmr.related_model.model_class == @source_model.name
          :inverse
        else
          raise ArgumentError, "PMR #{@pmr_id} does not involve #{@source_model.name}"
        end
    end

    def target_model
      @target_model ||= (direction == :forward ? pmr.related_model.model_class
                           : pmr.primary_model.model_class).constantize
    end

    def rel_alias    = "rel_#{@pmr_id}"
    def target_alias = "tgt_#{@pmr_id}"

    def relationship_join
      src_id, src_type =
        direction == :forward ? %w[primary_record_id primary_record_type]
          : %w[related_record_id related_record_type]

      ActiveRecord::Base.sanitize_sql_array([
                                              "LEFT JOIN core_data_connector_relationships #{rel_alias} " \
                                                "ON #{rel_alias}.#{src_type} = ? " \
                                                "AND #{rel_alias}.#{src_id} = #{@source_model.table_name}.id " \
                                                "AND #{rel_alias}.project_model_relationship_id = ?",
                                              @source_model.name, @pmr_id
                                            ])
    end

    def target_join
      tgt_id, tgt_type =
        direction == :forward ? %w[related_record_id related_record_type]
          : %w[primary_record_id primary_record_type]

      ActiveRecord::Base.sanitize_sql_array([
                                              "LEFT JOIN #{target_model.table_name} #{target_alias} " \
                                                "ON #{target_alias}.id = #{rel_alias}.#{tgt_id} " \
                                                "AND #{rel_alias}.#{tgt_type} = ?",
                                              target_model.name
                                            ])
    end

    def user_defined_field?
      @field.start_with?('udf.')
    end

    def validate_column!
      return if target_model.column_names.include?(@field)
      raise ArgumentError, "Unknown column #{@field} on #{target_model.name}"
    end

    def quote(value)
      ActiveRecord::Base.connection.quote(value)
    end
  end
end