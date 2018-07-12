require 'spec_helper'

describe "Serialization" do
  let!(:user) do
    User.create! :name => 'Mr. White' do |user|
      user.properties(:dashboard).theme = 'white'
      user.properties(:calendar).scope = 'all'
    end
  end

  describe 'created properties' do
    it 'should be serialized' do
      user.reload

      dashboard_properties = user.property_objects.where(:var => 'dashboard').first
      calendar_properties = user.property_objects.where(:var => 'calendar').first

      expect(dashboard_properties.var).to eq('dashboard')
      expect(dashboard_properties.value).to eq({'theme' => 'white'})

      expect(calendar_properties.var).to eq('calendar')
      expect(calendar_properties.value).to eq({'scope' => 'all'})
    end
  end

  describe 'updated properties' do
    it 'should be serialized' do
      user.properties(:dashboard).update_attributes! :smart => true

      dashboard_properties = user.property_objects.where(:var => 'dashboard').first
      calendar_properties = user.property_objects.where(:var => 'calendar').first

      expect(dashboard_properties.var).to eq('dashboard')
      expect(dashboard_properties.value).to eq({'theme' => 'white', 'smart' => true})

      expect(calendar_properties.var).to eq('calendar')
      expect(calendar_properties.value).to eq({'scope' => 'all'})
    end
  end
end
