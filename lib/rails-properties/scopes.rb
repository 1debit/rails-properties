module RailsProperties
  module Scopes
    def with_properties
      result = joins("INNER JOIN properties ON #{properties_join_condition}")

      if ActiveRecord::VERSION::MAJOR < 5
        result.uniq
      else
        result.distinct
      end
    end

    def with_properties_for(var)
      raise ArgumentError.new('Symbol expected!') unless var.is_a?(Symbol)
      joins("INNER JOIN properties ON #{properties_join_condition} AND properties.var = '#{var}'")
    end

    def without_properties
      joins("LEFT JOIN properties ON #{properties_join_condition}").
      where('properties.id IS NULL')
    end

    def without_properties_for(var)
      raise ArgumentError.new('Symbol expected!') unless var.is_a?(Symbol)
      joins("LEFT JOIN properties ON  #{properties_join_condition} AND properties.var = '#{var}'").
      where('properties.id IS NULL')
    end

    def properties_join_condition
      "properties.target_id   = #{table_name}.#{primary_key} AND
       properties.target_type = '#{base_class.name}'"
    end
  end
end
