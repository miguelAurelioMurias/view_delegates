require 'rails_helper'
require 'byebug'

RSpec.describe ViewDelegates::ViewDelegate, type: :model do
  before do
    @property_a = 'One ruby string'
    @property_b = 'Other ruby string'
    @dummy = DummyModel.new(a: 'property a', b: ' Property b')
    @dummy.save
    @delegate = Admin::AdminTestDelegate.new(dummy: @dummy, my_property: 'My property test')
  end
  describe 'model' do
    it 'Should assign objects' do
      delegate_dummy_members = @delegate.dummy.members
      expect(delegate_dummy_members).to eq([:a])
    end
    it 'Should assign model properties to internal struct' do
      expect(@delegate.dummy.a).to eq(@dummy.a)
    end
  end
  describe 'property' do
    class TestClass < ViewDelegates::ViewDelegate
      property :one_string
      property :other_string
    end
    it 'Should assign properties' do
      test_dummy = TestClass.new(one_string: @property_a, other_string: @property_b)
      expect(test_dummy.one_string).to eq(@property_a)
      expect(test_dummy.other_string).to eq(@property_b)
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
    it 'Should render in a block' do
       @rendered_block = @delegate.render(:index, local_params: {})  do |renderized|
        "#-#{renderized}-#"
      end
      expect(@rendered_block).to match /#-#{@rendered}-#/
    end
  end
  describe 'polymorph' do
    before do
      @polymorph_a = PolymorphicDelegate.new(a:1)
      @polymorph_b = PolymorphicDelegate.new(a:2)
    end
    it 'Should return the correct instance' do
      expect(@polymorph_a.class).to eq(BasicDelegate)
      expect(@polymorph_b.class).to eq(PolymorphicDelegate)
      expect(@polymorph_b.class.view_path).to_not eq(@polymorph_a.class.view_path)
    end
  end
end
