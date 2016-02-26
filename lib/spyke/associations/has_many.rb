module Spyke
  module Associations
    class HasMany < Association
      def initialize(*args)
        super
        # register assocation chain
        register_association(parent)

        # default to association chain uri
        @options.reverse_merge!(uri: default_uri(name))
      end

      def load
        self
      end

      def assign_nested_attributes(incoming)
        incoming = incoming.values if incoming.is_a?(Hash)
        combined_attributes = combine_with_existing(incoming)
        clear_existing!
        combined_attributes.each do |attributes|
          build(attributes)
        end
      end

      private

        # Register association foreign keys/values on class instance level and add them to @params
        def register_association(parent)
          self.class.association_register.merge!(foreign_key => parent.id).map { |key,value| @params[key] = value }
        end

        def default_uri(name)
          self.class.association_register.map do |key, value|
            "#{key.to_s.gsub('_id','').tableize}/:#{key.to_s}"
          end.join('/') + "/#{name}/(:id)"
        end

        def combine_with_existing(incoming)
          return incoming unless primary_keys_present_in_existing?
          combined = embedded_attributes + incoming
          group_by_primary_key(combined).flat_map do |primary_key, hashes|
            if primary_key.present?
              hashes.reduce(:merge)
            else
              hashes
            end
          end
        end

        def group_by_primary_key(array)
          array.group_by { |h| h.with_indifferent_access[:id].to_s }
        end

        def primary_keys_present_in_existing?
          embedded_attributes && embedded_attributes.any? { |attr| attr.has_key?('id') }
        end

        def clear_existing!
          update_parent []
        end

        def embedded_attributes
          @embedded_attributes ||= parent.attributes.to_params[name]
        end

        def add_to_parent(record)
          parent.attributes[name] ||= []
          parent.attributes[name] << record
          record
        end
    end
  end
end
