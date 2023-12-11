module CoreDataConnector
  module Public
    class LinkedOpenDataSerializer < BaseSerializer

      def self.target_attributes(*attrs, &block)
        @target_attributes ||= []

        if attrs.present?
          if attrs.size == 1 && block.present?
            @target_attributes << { attrs[0] => block }
          else
            @target_attributes += attrs
          end
        end

        @target_attributes
      end

      def render_index(items)
        value = super

        {
          '@context': 'http://www.w3.org/ns/anno.jsonld',
          body: {
            format: 'application/json',
            type: 'Dataset',
            value: value
          },
          created: Time.now.strftime('%Y-%m-%d'),
          id: options[:url],
          motivation: 'describing',
          target: resolve_target,
          type: 'Annotation'
        }
      end

      def render_target(item)
        return {} if item.nil?

        serialized = {}

        # Set all of the base attributes
        self.class.target_attributes&.each do |a|
          extract_value serialized, item, a
        end

        serialized
      end

      def resolve_target
        item = options[:target]
        return {} if item.nil?

        serializer_class = "CoreDataConnector::Public::#{item.class.to_s.demodulize.pluralize}Serializer".constantize
        serializer = serializer_class.new(current_user)

        serializer.render_target(item)
      end
    end
  end
end