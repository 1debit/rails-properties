require 'spec_helper'

describe 'Queries performed' do
  context 'New record' do
    let!(:user) { User.new :name => 'Mr. Pink' }

    it 'should be saved by one SQL query' do
      expect {
        user.save!
      }.to perform_queries(1)
    end

    it 'should be saved with properties for one key by two SQL queries' do
      expect {
        user.properties(:dashboard).foo = 42
        user.properties(:dashboard).bar = 'string'
        user.save!
      }.to perform_queries(2)
    end

    it 'should be saved with properties for two keys by three SQL queries' do
      expect {
        user.properties(:dashboard).foo = 42
        user.properties(:dashboard).bar = 'string'
        user.properties(:calendar).bar = 'string'
        user.save!
      }.to perform_queries(3)
    end
  end

  context 'Existing record without properties' do
    let!(:user) { User.create! :name => 'Mr. Pink' }

    it 'should be saved without SQL queries' do
      expect {
        user.save!
      }.to perform_queries(0)
    end

    it 'should be saved with properties for one key by two SQL queries' do
      expect {
        user.properties(:dashboard).foo = 42
        user.properties(:dashboard).bar = 'string'
        user.save!
      }.to perform_queries(2)
    end

    it 'should be saved with properties for two keys by three SQL queries' do
      expect {
        user.properties(:dashboard).foo = 42
        user.properties(:dashboard).bar = 'string'
        user.properties(:calendar).bar = 'string'
        user.save!
      }.to perform_queries(3)
    end
  end

  context 'Existing record with properties' do
    let!(:user) do
      User.create! :name => 'Mr. Pink' do |user|
        user.properties(:dashboard).theme = 'pink'
        user.properties(:calendar).scope = 'all'
      end
    end

    it 'should be saved without SQL queries' do
      expect {
        user.save!
      }.to perform_queries(0)
    end

    it 'should be saved with properties for one key by one SQL queries' do
      expect {
        user.properties(:dashboard).foo = 42
        user.properties(:dashboard).bar = 'string'
        user.save!
      }.to perform_queries(1)
    end

    it 'should be saved with properties for two keys by two SQL queries' do
      expect {
        user.properties(:dashboard).foo = 42
        user.properties(:dashboard).bar = 'string'
        user.properties(:calendar).bar = 'string'
        user.save!
      }.to perform_queries(2)
    end

    it 'should be destroyed by two SQL queries' do
      expect {
        user.destroy
      }.to perform_queries(2)
    end

    it "should update properties by one SQL query" do
      expect {
        user.properties(:dashboard).update_attributes! :foo => 'bar'
      }.to perform_queries(1)
    end
  end
end
