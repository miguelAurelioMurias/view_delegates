require 'rails_helper'
require 'byebug'
RSpec.describe ViewDelegates::ViewDelegate, type: :model do
  before do
    @dummy = DummyModel.new(a: 'property a', b: 'property b')
    @dummy.save
    @delegate = Admin::AdminTestDelegate.new(dummy: @dummy, my_property: 'My property test')
  end
  describe 'model' do
    it 'Should assign objects' do
      delegate_dummy_members = @delegate.dummy.members
      expect(delegate_dummy_members).to eq([:a])
    end
  end
  describe 'render' do
    before do
      @rendered = @delegate.render(:index)
    end
    it 'Should render views' do
      expect(@rendered).to_not be_nil
    end
    it 'Should render model properties' do
      expect(@rendered).to match /#{@dummy.a}/
    end
    it 'Should render helpers' do
      expect(@rendered).to match /#{hello_world}/
    end
    it 'Should render delegate methods' do
      expect(@rendered).to match /#{@delegate.test_method}/
    end
    it 'Should render properties' do
      expect(@rendered).to match /#{@delegate.my_property}/
    end
    it 'Should hit the cache' do
      expect(@rendered).to eq(@delegate.delegate_cache.entries.last.value)
    end
  end

end
