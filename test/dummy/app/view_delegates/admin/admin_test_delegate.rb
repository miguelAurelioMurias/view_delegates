module Admin
  class AdminTestDelegate < ViewDelegates::ViewDelegate
    view_local :test_method
    property :my_property
    property :name
    model :dummy, properties: [:a]
    model_array :dummies, properties: [:b]
    helper :my_name_is
    cache true
    def test_method
      'test_method'
    end
    def my_name_is
      "My name is #{name}"
    end
  end
end
