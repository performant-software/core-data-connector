module CoreDataConnector
  module Export
    module Base
      extend ActiveSupport::Concern

      class_methods do
        def export_attribute(*attrs, &block)
          name, options = attrs

          @export_attrs ||= []
          @export_attrs << { name: name, block: block}.merge(options || {})
        end

        def export_attributes
          @export_attrs
        end
      end

      included do
        def to_export_csv
          hash = {}

          # Add attributes defined by the concrete-class
          self.class.export_attributes.each do |attr|
            name = attr[:name]

            # Extract the value for the attribute
            if attr[:block].present?
              value = instance_eval(&attr[:block])
            else
              value = self.send(attr[:name])
            end

            # Add the name/value pair to the CSV
            hash[name] = value
          end

          hash
        end
      end
    end
  end
end