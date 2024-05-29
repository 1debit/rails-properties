require 'rails-properties/property_object'
require 'rails-properties/configuration'
require 'rails-properties/base'
require 'rails-properties/scopes'

ActiveRecord::Base.class_eval do
  def self.has_properties(*args, &block)
    RailsProperties::Configuration.new(*args.unshift(self), &block)

    include RailsProperties::Base
    extend RailsProperties::Scopes
  end
end

