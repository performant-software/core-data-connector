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
        target = resolve_target

        {
          '@context': 'http://www.w3.org/ns/anno.jsonld',
          id: options[:url],
          type: 'AnnotationPage',
          partOf: {
            id: options[:url],
            label: I18n.t(
              'serialization.linked_open_data.annotation_page_label',
              klass: items.klass.to_s.demodulize.pluralize,
              target: target[:name]
            ),
            total: options[:count]
          },
          items: value.each_with_index.map{ |item, index| render_annotation(item, index, target) }
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

      private

      def render_annotation(item, index, target)
        {
          type: 'Annotation',
          id: index,
          created: DateTime.now.to_s,
          motivation: 'linking',
          target: target,
          body: item
        }
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