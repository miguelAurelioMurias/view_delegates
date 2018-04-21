require 'rails_helper'
RSpec.describe ViewDelegates::Cache, type: :model do
  before do
    @cache = ViewDelegates::Cache.new max_size: 4
    @first_entry = 1
    @second_entry = 2
    @third_entry = 3
    @last_entry = 4
    @cache.add key: 1, value: @first_entry
    @cache.add key: 2, value: @second_entry
    @cache.add key: 3, value: @third_entry
  end
  describe 'add' do
    it 'Should add a new entry' do
      size_before = @cache.entries.length
      @cache.add key: 4, value: @last_entry
      expect(@cache.entries.length).to eq(size_before + 1)
      expect(@cache.entries.last.value).to eq(@last_entry)
    end
    it 'Should remove the first element when the max size is reached' do
      @cache.add key: 4, value: @last_entry
      @cache.add key: 5, value: 5
      expect(@cache.entries.first.value).to eq(2)
    end
  end
  describe 'get' do
    it 'Should return nil on non existant values' do
      expect(@cache.get(5)).to be_nil
    end
    it 'Should fetch a value' do
      fetched = @cache.get 2
      expect(fetched).to eq(@second_entry)
    end
    it 'Should have reordered elements' do
      @cache.get 2
      expect(@cache.entries.index { |e| e.value == @second_entry }).to eq(2)
      @cache.get 1
      expect(@cache.entries.index { |e| e.value == @first_entry }).to eq(1)
    end
    it 'The last element should stay on the same position' do
      @cache.get 3
      expect(@cache.entries.index { |e| e.value == @third_entry }).to eq(2)
    end
  end
end
