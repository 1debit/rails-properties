require 'spec_helper'

describe "Defaults" do
  it "should be stored for simple class" do
    expect(Account.default_properties).to eq(:portal => {})
  end

  it "should be stored for parent class" do
    expect(User.default_properties).to eq(:dashboard => { 'theme' => 'blue', 'view' => 'monthly', 'filter' => true },
                                    :calendar => { 'scope' => 'company'})
  end

  it "should be stored for child class" do
    expect(GuestUser.default_properties).to eq(:dashboard => { 'theme' => 'red', 'view' => 'monthly', 'filter' => true })
  end
end

describe "Getter/Setter" do
  let(:account) { Account.new :subdomain => 'foo' }

  it "should handle method syntax" do
    account.properties(:portal).enabled = true
    account.properties(:portal).template = 'black'

    expect(account.properties(:portal).enabled).to eq(true)
    expect(account.properties(:portal).template).to eq('black')
  end

  it "should return nil for not existing key" do
    expect(account.properties(:portal).foo).to eq(nil)
  end
end

describe 'Objects' do
  context 'without defaults' do
    let(:account) { Account.new :subdomain => 'foo' }

    it 'should have blank properties' do
      expect(account.properties(:portal).value).to eq({})
    end

    it 'should allow saving a blank value' do
      account.save!
      expect(account.properties(:portal).save).to be_truthy
    end

    it 'should allow removing all values' do
      account.properties(:portal).premium = true
      account.properties(:portal).fee = 42.5
      account.save!

      account.properties(:portal).premium = nil
      expect(account.save).to be_truthy

      account.properties(:portal).fee = nil
      expect(account.save).to be_truthy
    end

    it 'should not add properties on saving' do
      account.save!
      expect(RailsProperties::PropertyObject.count).to eq(0)
    end

    it "should save object with properties" do
      account.properties(:portal).premium = true
      account.properties(:portal).fee = 42.5
      account.save!

      account.reload
      expect(account.properties(:portal).premium).to eq(true)
      expect(account.properties(:portal).fee).to eq(42.5)

      expect(RailsProperties::PropertyObject.count).to eq(1)
      expect(RailsProperties::PropertyObject.first.value).to eq({ 'premium' => true, 'fee' => 42.5 })
    end

    it "should save properties separated" do
      account.save!

      properties = account.properties(:portal)
      properties.enabled = true
      properties.template = 'black'
      properties.save!

      account.reload
      expect(account.properties(:portal).enabled).to eq(true)
      expect(account.properties(:portal).template).to eq('black')
    end
  end

  context 'with defaults' do
    let(:user) { User.new :name => 'Mr. Brown' }

    it 'should have default properties' do
      expect(user.properties(:dashboard).theme).to eq('blue')
      expect(user.properties(:dashboard).view).to eq('monthly')
      expect(user.properties(:dashboard).filter).to eq(true)
      expect(user.properties(:calendar).scope).to eq('company')
    end

    it 'should have default properties after changing one' do
      user.properties(:dashboard).theme = 'gray'

      expect(user.properties(:dashboard).theme).to eq('gray')
      expect(user.properties(:dashboard).view).to eq('monthly')
      expect(user.properties(:dashboard).filter).to eq(true)
      expect(user.properties(:calendar).scope).to eq('company')
    end

    it "should overwrite properties" do
      user.properties(:dashboard).theme = 'brown'
      user.properties(:dashboard).filter = false
      user.save!

      user.reload
      expect(user.properties(:dashboard).theme).to eq('brown')
      expect(user.properties(:dashboard).filter).to eq(false)
      expect(RailsProperties::PropertyObject.count).to eq(1)
      expect(RailsProperties::PropertyObject.first.value).to eq({ 'theme' => 'brown', 'filter' => false })
    end

    it "should merge properties with defaults" do
      user.properties(:dashboard).theme = 'brown'
      user.save!

      user.reload
      expect(user.properties(:dashboard).theme).to eq('brown')
      expect(user.properties(:dashboard).filter).to eq(true)
      expect(RailsProperties::PropertyObject.count).to eq(1)
      expect(RailsProperties::PropertyObject.first.value).to eq({ 'theme' => 'brown' })
    end
  end
end

describe "Object without properties" do
  let!(:user) { User.create! :name => 'Mr. White' }

  it "should respond to #properties?" do
    expect(user.properties?).to eq(false)
    expect(user.properties?(:dashboard)).to eq(false)
  end

  it "should have no property objects" do
    expect(RailsProperties::PropertyObject.count).to eq(0)
  end

  it "should add properties" do
    user.properties(:dashboard).update_attributes! :smart => true

    user.reload
    expect(user.properties(:dashboard).smart).to eq(true)
  end

  it "should not save properties if assigned nil" do
    expect {
      user.properties = nil
      user.save!
    }.to_not change(RailsProperties::PropertyObject, :count)
  end
end

describe "Object with properties" do
  let!(:user) do
    User.create! :name => 'Mr. White' do |user|
      user.properties(:dashboard).theme = 'white'
      user.properties(:calendar).scope = 'all'
    end
  end

  it "should respond to #properties?" do
    expect(user.properties?).to eq(true)

    expect(user.properties?(:dashboard)).to eq(true)
    expect(user.properties?(:calendar)).to eq(true)
  end

  it "should have two property objects" do
    expect(RailsProperties::PropertyObject.count).to eq(2)
  end

  it "should update properties" do
    user.properties(:dashboard).update_attributes! :smart => true
    user.reload

    expect(user.properties(:dashboard).smart).to eq(true)
    expect(user.properties(:dashboard).theme).to eq('white')
    expect(user.properties(:calendar).scope).to eq('all')
  end

  it "should update properties by saving object" do
    user.properties(:dashboard).smart = true
    user.save!

    user.reload
    expect(user.properties(:dashboard).smart).to eq(true)
  end

  it "should destroy properties with nil" do
    expect {
      user.properties = nil
      user.save!
    }.to change(RailsProperties::PropertyObject, :count).by(-2)

    expect(user.properties?).to eq(false)
  end

  it "should raise exception on assigning other than nil" do
    expect {
      user.properties = :foo
      user.save!
    }.to raise_error(ArgumentError)
  end
end

describe "Customized PropertyObject" do
  let(:project) { Project.create! :name => 'Heist' }

  it "should not accept invalid attributes" do
    project.properties(:info).owner_name = 42
    expect(project.properties(:info)).not_to be_valid

    project.properties(:info).owner_name = ''
    expect(project.properties(:info)).not_to be_valid
  end

  it "should accept valid attributes" do
    project.properties(:info).owner_name = 'Mr. Brown'
    expect(project.properties(:info)).to be_valid
  end
end

describe "to_properties_hash" do
  let(:user) do
    User.new :name => 'Mrs. Fin' do |user|
      user.properties(:dashboard).theme = 'green'
      user.properties(:dashboard).sound = 11
      user.properties(:calendar).scope = 'some'
    end
  end

  it "should return defaults" do
    expect(User.new.to_properties_hash).to eq({:dashboard=>{"theme"=>"blue", "view"=>"monthly", "filter"=>true}, :calendar=>{"scope"=>"company"}})
  end

  it "should return merged properties" do
    expect(user.to_properties_hash).to eq({:dashboard=>{"theme"=>"green", "view"=>"monthly", "filter"=>true, "sound" => 11}, :calendar=>{"scope"=>"some"}})
  end
end
