module RailsProperties
  module Base
    def self.included(base)
      base.class_eval do
        has_many :property_objects,
                 :as         => :target,
                 :autosave   => true,
                 :dependent  => :delete_all,
                 :class_name => self.property_object_class_name

        def properties(var)
          raise ArgumentError unless var.is_a?(Symbol)
          raise ArgumentError.new("Unknown key: #{var}") unless self.class.default_properties[var]

          if RailsProperties.can_protect_attributes?
            property_objects.detect { |s| s.var == var.to_s } || property_objects.build({ :var => var.to_s }, :without_protection => true)
          else
            property_objects.detect { |s| s.var == var.to_s } || property_objects.build(:var => var.to_s, :target => self)
          end
        end

        def properties=(value)
          if value.nil?
            property_objects.each(&:mark_for_destruction)
          else
            raise ArgumentError
          end
        end

        def properties?(var=nil)
          if var.nil?
            property_objects.any? { |property_object| !property_object.marked_for_destruction? && property_object.value.present? }
          else
            properties(var).value.present?
          end
        end

        def to_properties_hash
          properties_hash = self.class.default_properties.dup
          properties_hash.each do |var, vals|
            properties_hash[var] = properties_hash[var].merge(properties(var.to_sym).value)
          end
          properties_hash
        end
      end
    end
  end
end
