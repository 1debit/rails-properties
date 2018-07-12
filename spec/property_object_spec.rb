require 'spec_helper'

describe RailsProperties::PropertyObject do
  let(:user) { User.create! :name => 'Mr. Pink' }

  if RailsProperties.can_protect_attributes?
    let(:new_property_object) { user.property_objects.build({ :var => 'dashboard'}, :without_protection => true) }
    let(:saved_property_object) { user.property_objects.create!({ :var => 'dashboard', :value => { 'theme' => 'pink', 'filter' => false}}, :without_protection => true) }
  else
    let(:new_property_object) { user.property_objects.build({ :var => 'dashboard'}) }
    let(:saved_property_object) { user.property_objects.create!({ :var => 'dashboard', :value => { 'theme' => 'pink', 'filter' => false}}) }
  end

  describe "serialization" do
    it "should have a hash default" do
      expect(RailsProperties::PropertyObject.new.value).to eq({})
    end
  end

  describe "Getter and Setter" do
    context "on unsaved properties" do
      it "should respond to setters" do
        expect(new_property_object).to respond_to(:foo=)
        expect(new_property_object).to respond_to(:bar=)
      end

      it "should not respond to some getters" do
        expect { new_property_object.foo! }.to raise_error(NoMethodError)
        expect { new_property_object.foo? }.to raise_error(NoMethodError)
      end

      it "should not respond if a block is given" do
        expect {
          new_property_object.foo do
          end
        }.to raise_error(NoMethodError)
      end

      it "should not respond if params are given" do
        expect { new_property_object.foo(42) }.to raise_error(NoMethodError)
        expect { new_property_object.foo(42,43) }.to raise_error(NoMethodError)
      end

      it "should return nil for unknown attribute" do
        expect(new_property_object.foo).to eq(nil)
        expect(new_property_object.bar).to eq(nil)
      end

      it "should return defaults" do
        expect(new_property_object.theme).to eq('blue')
        expect(new_property_object.view).to eq('monthly')
        expect(new_property_object.filter).to eq(true)
      end

      it "should return defaults when using `try`" do
        expect(new_property_object.try(:theme)).to eq('blue')
        expect(new_property_object.try(:view)).to eq('monthly')
        expect(new_property_object.try(:filter)).to eq(true)
      end

      it "should store different objects to value hash" do
        new_property_object.integer = 42
        new_property_object.float   = 1.234
        new_property_object.string  = 'Hello, World!'
        new_property_object.array   = [ 1,2,3 ]
        new_property_object.symbol  = :foo

        expect(new_property_object.value).to eq('integer' => 42,
                                           'float'   => 1.234,
                                           'string'  => 'Hello, World!',
                                           'array'   => [ 1,2,3 ],
                                           'symbol'  => :foo)
      end

      it "should set and return attributes" do
        new_property_object.theme = 'pink'
        new_property_object.foo = 42
        new_property_object.bar = 'hello'

        expect(new_property_object.theme).to eq('pink')
        expect(new_property_object.foo).to eq(42)
        expect(new_property_object.bar).to eq('hello')
      end

      it "should set dirty trackers on change" do
        new_property_object.theme = 'pink'
        expect(new_property_object).to be_value_changed
        expect(new_property_object).to be_changed
      end
    end

    context "on saved properties" do
      it "should not set dirty trackers on property same value" do
        saved_property_object.theme = 'pink'
        expect(saved_property_object).not_to be_value_changed
        expect(saved_property_object).not_to be_changed
      end

      it "should delete key on assigning nil" do
        saved_property_object.theme = nil
        expect(saved_property_object.value).to eq({ 'filter' => false })
      end
    end
  end

  describe "update_attributes" do
    it 'should save' do
      expect(new_property_object.update_attributes(:foo => 42, :bar => 'string')).to be_truthy
      new_property_object.reload

      expect(new_property_object.foo).to eq(42)
      expect(new_property_object.bar).to eq('string')
      expect(new_property_object).not_to be_new_record
      expect(new_property_object.id).not_to be_zero
    end

    it 'should not save blank hash' do
      expect(new_property_object.update_attributes({})).to be_truthy
    end

    if RailsProperties.can_protect_attributes?
      it 'should not allow changing protected attributes' do
        new_property_object.update_attributes!(:var => 'calendar', :foo => 42)

        expect(new_property_object.var).to eq('dashboard')
        expect(new_property_object.foo).to eq(42)
      end
    end
  end

  describe "save" do
    it "should save" do
      new_property_object.foo = 42
      new_property_object.bar = 'string'
      expect(new_property_object.save).to be_truthy
      new_property_object.reload

      expect(new_property_object.foo).to eq(42)
      expect(new_property_object.bar).to eq('string')
      expect(new_property_object).not_to be_new_record
      expect(new_property_object.id).not_to be_zero
    end
  end

  describe "validation" do
    it "should not validate for unknown var" do
      new_property_object.var = "unknown-var"

      expect(new_property_object).not_to be_valid
      expect(new_property_object.errors[:var]).to be_present
    end
  end
end
