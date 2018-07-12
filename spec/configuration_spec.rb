require 'spec_helper'

module RailsProperties
  class Dummy
  end

  describe Configuration, 'successful' do
    it "should define single key" do
      Configuration.new(Dummy, :dashboard)

      expect(Dummy.default_properties).to eq({ :dashboard => {} })
      expect(Dummy.property_object_class_name).to eq('RailsProperties::PropertyObject')
    end

    it "should define multiple keys" do
      Configuration.new(Dummy, :dashboard, :calendar)

      expect(Dummy.default_properties).to eq({ :dashboard => {}, :calendar => {} })
      expect(Dummy.property_object_class_name).to eq('RailsProperties::PropertyObject')
    end

    it "should define single key with class_name" do
      Configuration.new(Dummy, :dashboard, :class_name => 'MyClass')
      expect(Dummy.default_properties).to eq({ :dashboard => {} })
      expect(Dummy.property_object_class_name).to eq('MyClass')
    end

    it "should define multiple keys with class_name" do
      Configuration.new(Dummy, :dashboard, :calendar, :class_name => 'MyClass')

      expect(Dummy.default_properties).to eq({ :dashboard => {}, :calendar => {} })
      expect(Dummy.property_object_class_name).to eq('MyClass')
    end

    it "should define using block" do
      Configuration.new(Dummy) do |c|
        c.key :dashboard
        c.key :calendar
      end

      expect(Dummy.default_properties).to eq({ :dashboard => {}, :calendar => {} })
      expect(Dummy.property_object_class_name).to eq('RailsProperties::PropertyObject')
    end

    it "should define using block with defaults" do
      Configuration.new(Dummy) do |c|
        c.key :dashboard, :defaults => { :theme => 'red' }
        c.key :calendar, :defaults => { :scope => 'all' }
      end

      expect(Dummy.default_properties).to eq({ :dashboard => { 'theme' => 'red' }, :calendar => { 'scope' => 'all'} })
      expect(Dummy.property_object_class_name).to eq('RailsProperties::PropertyObject')
    end

    it "should define using block and class_name" do
      Configuration.new(Dummy, :class_name => 'MyClass') do |c|
        c.key :dashboard
        c.key :calendar
      end

      expect(Dummy.default_properties).to eq({ :dashboard => {}, :calendar => {} })
      expect(Dummy.property_object_class_name).to eq('MyClass')
    end
  end

  describe Configuration, 'failure' do
    it "should fail without args" do
      expect {
        Configuration.new
      }.to raise_error(ArgumentError)
    end

    it "should fail without keys" do
      expect {
        Configuration.new(Dummy)
      }.to raise_error(ArgumentError)
    end

    it "should fail without keys in block" do
      expect {
        Configuration.new(Dummy) do |c|
        end
      }.to raise_error(ArgumentError)
    end

    it "should fail with keys not being symbols" do
      expect {
        Configuration.new(Dummy, 42, "string")
      }.to raise_error(ArgumentError)
    end

    it "should fail with keys not being symbols" do
      expect {
        Configuration.new(Dummy) do |c|
          c.key 42, "string"
        end
      }.to raise_error(ArgumentError)
    end

    it "should fail with unknown option" do
      expect {
        Configuration.new(Dummy) do |c|
          c.key :dashboard, :foo => {}
        end
      }.to raise_error(ArgumentError)
    end
  end
end
