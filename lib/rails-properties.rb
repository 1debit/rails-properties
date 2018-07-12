module RailsProperties
  # In Rails 3, attributes can be protected by `attr_accessible` and `attr_protected`
  # In Rails 4, attributes can be protected by using the gem `protected_attributes`
  # In Rails 5, protecting attributes is obsolete (there are `StrongParameters` only)
  def self.can_protect_attributes?
    (ActiveRecord::VERSION::MAJOR == 3) || defined?(ProtectedAttributes)
  end
end

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

