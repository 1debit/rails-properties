module RailsProperties
  class PropertyObject < ActiveRecord::Base
    self.table_name = 'properties'

    belongs_to :target, :polymorphic => true

    validates_presence_of :var, :target_type
    validate do
      errors.add(:value, "Invalid property value") unless value.is_a? Hash

      unless _target_class.default_properties[var.to_sym]
        errors.add(:var, "#{var} is not defined!")
      end
    end

    serialize :value, Hash

    REGEX_SETTER = /\A([a-z]\w+)=\Z/i
    REGEX_GETTER = /\A([a-z]\w+)\Z/i

    def respond_to?(method_name, include_priv=false)
      super || method_name.to_s =~ REGEX_SETTER || _property?(method_name)
    end

    def method_missing(method_name, *args, &block)
      if block_given?
        super
      else
        if attribute_names.include?(method_name.to_s.sub('=',''))
          super
        elsif method_name.to_s =~ REGEX_SETTER && args.size == 1
          _set_value($1, args.first)
        elsif method_name.to_s =~ REGEX_GETTER && args.size == 0
          _get_value($1)
        else
          super
        end
      end
    end

  private
    def _get_value(name)
      if value[name].nil?
        _target_class.default_properties[var.to_sym][name]
      else
        value[name]
      end
    end

    def _set_value(name, v)
      if value[name] != v
        value_will_change!

        if v.nil?
          value.delete(name)
        else
          value[name] = v
        end
      end
    end

    def _target_class
      target_type.constantize
    end

    def _property?(method_name)
      _target_class.default_properties[var.to_sym].keys.include?(method_name.to_s)
    end
  end
end
