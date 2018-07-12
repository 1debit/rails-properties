require 'spec_helper'

describe 'scopes' do
  let!(:user1) { User.create! :name => 'Mr. White' do |user| user.properties(:dashboard).theme = 'white' end }
  let!(:user2) { User.create! :name => 'Mr. Blue' }

  it "should find objects with existing properties" do
    expect(User.with_properties).to eq([user1])
  end

  it "should find objects with properties for key" do
    expect(User.with_properties_for(:dashboard)).to eq([user1])
    expect(User.with_properties_for(:foo)).to eq([])
  end

  it "should records without properties" do
    expect(User.without_properties).to eq([user2])
  end

  it "should records without properties for key" do
    expect(User.without_properties_for(:foo)).to eq([user1, user2])
    expect(User.without_properties_for(:dashboard)).to eq([user2])
  end

  it "should require symbol as key" do
    [ nil, "string", 42 ].each do |invalid_key|
      expect { User.without_properties_for(invalid_key) }.to raise_error(ArgumentError)
      expect { User.with_properties_for(invalid_key)    }.to raise_error(ArgumentError)
    end
  end
end
